namespace :docker do
  namespace :assets do
    task :precompile do
      on roles(fetch(:docker_role)) do
        execute :docker, task_command(fetch(:docker_assets_precompile_command))
      end
    end
  end
  namespace :compose do
    namespace :assets do
      task :precompile do
        on roles(fetch(:docker_role)) do
          execute :"docker-compose", compose_run_command(fetch(:docker_compose_assets_precompile_container), fetch(:docker_compose_assets_precompile_command))
        end
      end
    end
  end
end

if fetch(:docker_compose) == true
  before "docker:deploy:compose:start", "docker:compose:assets:precompile"
else
  before "docker:deploy:default:run", "docker:assets:precompile"
end
