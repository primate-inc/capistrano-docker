namespace :docker do
  namespace :migration do
    task :create do
      on roles(fetch(:docker_role)) do
        execute :docker, task_command(fetch(:docker_db_create_command))
      end
    end
    
    task :migrate do
      on roles(fetch(:docker_role)) do
        execute :docker, task_command(fetch(:docker_migrate_command))
      end
    end
  end
  namespace :compose do
    namespace :db do
      task :migrate do
        on roles(fetch(:docker_role)) do
          execute :"docker-compose", compose_run_command(fetch(:docker_compose_db_migrate_container), fetch(:docker_compose_db_migrate_command))
        end
      end
    end
  end
end

if fetch(:docker_compose) == true
  before "docker:deploy:compose:start", "docker:compose:db:migrate"
else
  before "docker:deploy:default:run", "docker:migration:migrate"
end
