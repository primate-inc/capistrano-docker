namespace :docker do
  namespace :compose do
    task :start do
      invoke "docker:deploy:compose:start"
    end

    task :stop do
      invoke "docker:deploy:compose:stop"
    end

    task :down do
      invoke "docker:deploy:compose:down"
    end
  end

  namespace :deploy do
    task :compose do
      %w( validate prepare build start ).each do |task|
        invoke "docker:deploy:compose:#{task}"
      end
    end

    namespace :compose do
      task :validate do
        fetch(:docker_pass_env).each do |env|
          raise "missing #{env} environment variable" if ENV[env].nil?
        end
      end

      task :prepare do
        invoke "docker:deploy:default:prepare"
      end

      task :build do
        on roles(fetch(:docker_role)) do
          within release_path do
            execute :"docker-compose", compose_build_command
          end
        end
      end
      before :build, "docker:prepare_environment"

      task :start do
        on roles(fetch(:docker_role)) do
          within release_path do
            execute :"docker-compose", compose_start_command
          end
        end
      end
      before :start, "docker:prepare_environment"

      task :stop do
        on roles(fetch(:docker_role)) do
          within release_path do
            execute :"docker-compose", compose_stop_command
            execute :"docker-compose", compose_remove_command unless fetch(:docker_compose_remove_after_stop) == false
          end
        end
      end
      before :stop, "docker:prepare_environment"

      task :down do
        on roles(fetch(:docker_role)) do
          within release_path do
            execute :"docker-compose", compose_down_command
          end
        end
      end
      before :down, "docker:prepare_environment"
    end
  end

  def _compose_option_environment_file
    opt = fetch(:docker_compose_environment_file)
    opt.nil? ? "" : "--env-file #{opt}"
  end

  def _compose_option_project_name
    opt = fetch(:docker_compose_project_name)
    opt.nil? ? "" : "-p #{opt}"
  end

  def _compose_option_compose_path
    opt = Array(fetch(:docker_compose_path))
    opt.empty? ? "" : "-f #{opt.join(" -f ")}"
  end

  def _compose_option_build_services
    opt = fetch(:docker_compose_build_services)
    opt.nil? ? "" : opt
  end

  def compose_start_command
    cmd = ["up", "-d"]
    cmd << _compose_option_build_services
    cmd.unshift _compose_option_project_name
    cmd.unshift _compose_option_compose_path
    cmd.unshift _compose_option_environment_file

    cmd.join(" ")
  end

  def compose_build_command
    cmd = ["build"]
    cmd << _compose_option_build_services
    cmd.unshift _compose_option_project_name
    cmd.unshift _compose_option_compose_path
    cmd.unshift _compose_option_environment_file

    cmd.join(" ")
  end

  def compose_stop_command
    cmd = ["stop"]
    cmd.unshift _compose_option_project_name
    cmd.unshift _compose_option_compose_path
    cmd.unshift _compose_option_environment_file
    cmd.join(" ")
  end

  def compose_remove_command
    cmd = ["rm"]
    cmd.unshift _compose_option_project_name
    cmd.unshift _compose_option_compose_path
    cmd.unshift _compose_option_environment_file
    cmd << "-f"
    cmd << "-v" if fetch(:docker_compose_remove_volumes) == true

    cmd.join(" ")
  end

  def compose_down_command
    cmd = ["down"]
    cmd.unshift _compose_option_project_name
    cmd.unshift _compose_option_compose_path
    cmd.unshift _compose_option_environment_file
    cmd.join(" ")
  end

  def compose_run_command(service, command)
    cmd = ["run"]
    cmd.unshift _compose_option_project_name
    cmd.unshift _compose_option_compose_path
    cmd.unshift _compose_option_environment_file

    cmd << service
    cmd << command

    cmd.join(" ")
  end
end
