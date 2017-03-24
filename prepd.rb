require 'csv'
require 'securerandom'
require 'mkmf'

module Prepd
  class Project
    attr_accessor :tf_creds, :tf_key, :tf_secret, :ansible_creds, :ansible_key, :ansible_secret
    attr_accessor :repo_url

    #
    # Initialize the prepd-project or just copy in developer credentials if the project already exists
    #
    def create
      STDOUT.puts '### Running prepd'
      # configure
      setup_git
      clone_submodules
      copy_developer_yml
      generate_credentials
      encrypt_vault_files
      commit_git
    end

    # NOTE: Re-enable this function if/when there is a need for the user to modify values
    # before running 'vagrant up' for the first time
    # def configure
    #   return unless File.exist?('.prepd.yml')
    #   require 'yaml'
    #   prepd_conf = YAML.load_file('.prepd.yml')
    #   prepd_conf.each { |k, v| send("#{k}=", v) }
    # end

    #
    # Clone prepd-project, remove the git history and start with a clean repository
    #
    def setup_git
      Dir.chdir(path) do
        FileUtils.rm_rf(".git")
        system('git init')
      end
    end

    def commit_git
      Dir.chdir(path) do
        system('git add .')
        system("git commit -m 'First commit from Prepd'")
        system("git remote add origin #{repo_url}") if repo_url
      end
   end

    #
    # Clone ansible roles and terraform modules
    #
    def clone_submodules
      Dir.chdir("#{path}/ansible") do
        system('git submodule add git@github.com:rjayroach/ansible-roles.git roles')
      end
      Dir.chdir("#{path}/terraform") do
        system('git submodule add git@github.com:rjayroach/terraform-modules.git modules')
      end
    end

    #
    # Copy developer credentials or create them if the file doesn't already exists
    #
    def copy_developer_yml
      Dir.chdir(creds_path) do
        return if File.exists?("developer.yml")
        File.open('developer.yml', 'w') do |f|
          f.puts('---')
          f.puts("git_username: #{`git config --get user.name`.chomp}")
          f.puts("git_email: #{`git config --get user.email`.chomp}")
          f.puts("docker_username: ")
          f.puts("docker_password: ")
        end
      end
    end

    #
    # Create AWS credential files for Terraform and Ansible, ssh keys and and ansible-vault encryption key
    # NOTE: The path to credentials is used in the ansible-role prepd
    #
    def generate_credentials
      generate_tf_creds
      generate_ansible_creds
      generate_ssh_keys
      generate_vault_password
    end

    #
    # By default, look for downloaded AWS credentials in CSV format in these locations
    #
    def tf_creds
      @tf_creds ||= "#{creds_path}/terraform/default.csv"
    end

    def ansible_creds
      @ansible_creds ||= "#{creds_path}/boto.csv"
    end

    def generate_tf_creds
      self.tf_key, self.tf_secret = CSV.read(tf_creds).last.slice(2,2) if File.exists?(tf_creds)
      unless tf_key and tf_secret
        STDOUT.puts 'tf_key and tf_secret need to be set (or set tf_creds to path to CSV file)'
        return
      end
      Dir.chdir(creds_path) do
        FileUtils.mkdir_p 'terraform'
        File.open('terraform/default.tfvars', 'w') do |f|
          f.puts("aws_access_key_id = \"#{tf_key}\"")
          f.puts("aws_secret_access_key = \"#{tf_secret}\"")
        end
      end
    end

    def generate_ansible_creds
      self.ansible_key, self.ansible_secret = CSV.read(ansible_creds).last.slice(2,2) if File.exists?(ansible_creds)
      unless ansible_key and ansible_secret
        STDOUT.puts 'ansible_key and ansible_secret need to be set (or set ansible_creds to path to CSV file)'
        return
      end
      Dir.chdir(creds_path) do
        File.open('boto', 'w') do |f|
          f.puts('[profile default]')
          f.puts("aws_access_key_id = #{ansible_key}")
          f.puts("aws_secret_access_key = #{ansible_secret}")
        end
      end
    end

    #
    # Generate a key pair to be used as the EC2 key pair
    #
    def generate_ssh_keys(file_name = 'id_rsa')
      Dir.chdir(creds_path) { system("ssh-keygen -b 2048 -t rsa -f #{file_name} -q -N '' -C 'ansible@#{host_name}.local'") }
    end

    #
    # Generate the key to encrypt ansible-vault files
    #
    def generate_vault_password(file_name = 'vault-password.txt')
      require 'securerandom'
      Dir.chdir(creds_path) { File.open(file_name, 'w') { |f| f.puts(SecureRandom.uuid) } }
    end

    #
    # Use ansible-vault to encrypt the inventory group_vars
    #
    def encrypt_vault_files
      Dir.chdir("#{path}/ansible") do
        %w(all development local production staging).each do |env|
          system("ansible-vault encrypt group_vars/#{env}/vault")
        end
      end
    end

    def encrypt(mode = :vault)
      return unless executable?('gpg')
      Dir.chdir(path) do
        system "tar cf #{archive(:credentials)} #{file_list(mode)}"
      end
      system "gpg -c #{archive(:credentials)}"
      FileUtils.rm(archive(:credentials))
      "File created: #{archive(:credentials)}.gpg"
    end

    def encrypt_data
      return unless executable?('gpg')
      Dir.chdir(path) do
        system "tar cf #{archive(:data)} data"
      end
      system "gpg -c #{archive(:data)}"
      FileUtils.rm(archive(:data))
      "File created: #{archive(:data)}.gpg"
    end

    def decrypt(type = :credentials)
      return unless %i(credentials data).include? type
      return unless executable?('gpg')
      unless File.exists?("#{archive(type)}.gpg")
        STDOUT.puts "File not found: #{archive(type)}.gpg"
        return
      end
      system "gpg #{archive(type)}.gpg"
      Dir.chdir(path) do
        system "tar xf #{archive(type)}"
      end
      FileUtils.rm(archive(type))
      "File processed: #{archive(type)}.gpg"
    end

    def executable?(name = 'gpg')
      require 'mkmf'
      rv = find_executable(name)
      STDOUT.puts "#{name} executable not found" unless rv
      FileUtils.rm('mkmf.log')
      rv
    end

    def file_list(mode)
      return "boto id_rsa id_rsa.pub terraform/default.tfvars vault-password.txt" if mode.eql?(:all)
      "vault-password.txt"
    end

    def archive(type = :credentials)
      t_path = type.eql?(:credentials) ? data_path : path
      "#{t_path}/#{host_name('-')}-#{type}.tar"
    end

    def host_name(delimiter = '.')
      Dir.pwd.split('/').pop(2).reverse.join(delimiter)
    end

    def data_path
      "#{path}/data"
    end

    def creds_path
      "#{data_path}/credentials"
    end

    def path
      '.'
    end
  end
end
