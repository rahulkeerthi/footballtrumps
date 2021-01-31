generators = <<~RUBY
  config.generators do |generate|
    generate.assets false
    generate.helper false
    generate.test_framework :test_unit, fixture: false
  end
RUBY

environment generators

run 'yarn add popper.js jquery bootstrap'
append_file 'app/javascript/packs/application.js', <<~JS

  // External imports
  import "bootstrap";
  // Internal imports, e.g:
  // import { initSelect2 } from '../components/init_select2';
  document.addEventListener('turbolinks:load', () => {
    // Call your functions here, e.g:
    // initSelect2();
  });
JS

inject_into_file 'config/webpack/environment.js', before: 'module.exports' do
  <<~JS
    const webpack = require('webpack');
    // Preventing Babel from transpiling NodeModules packages
    environment.loaders.delete('nodeModules');
    // Bootstrap 4 has a dependency over jQuery & Popper.js:
    environment.plugins.prepend('Provide',
      new webpack.ProvidePlugin({
        $: 'jquery',
        jQuery: 'jquery',
        Popper: ['popper.js', 'default']
      })
    );
  JS
end

# Dotenv
########################################
run 'touch .env'

# Rubocop
########################################
run 'curl -L https://raw.githubusercontent.com/lewagon/rails-templates/master/.rubocop.yml > .rubocop.yml'

gsub_file('config/puma.rb', 'pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }', '# pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }')
