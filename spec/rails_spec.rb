describe Figaro::Rails, type: :aruba do
  def patch_for_rails7
    # Rails 7 doesn't expect the config.assets line, so comment it out or delete references to it
    replace_into_file("config/environments/development.rb", " config.assets", "# config.assets")
    remove("config/initializers/assets.rb")
  end

  before do
    run_command_and_stop(<<-CMD)
      rails new example \
        --skip-gemfile \
        --skip-git \
        --skip-keeps \
        --skip-sprockets \
        --skip-spring \
        --skip-listen \
        --skip-javascript \
        --skip-turbolinks \
        --skip-test \
        --skip-bootsnap \
        --no-rc \
        --skip-bundle \
        --skip-webpack-install
      CMD

    cd("example")

    patch_for_rails7 if `rails -v`.include?('Rails 7')
  end

  describe "initialization" do
    before do
      write_file("config/application.yml", "foo: bar")
    end

    it "loads application.yml" do
      run_command_and_stop("rails runner 'puts Figaro.env.foo'")

      expect(all_stdout).to include("bar")
    end

    it "happens before database initialization" do
      write_file("config/database.yml", <<-EOF)
development:
  adapter: sqlite3
  database: db/<%= ENV["foo"] %>.sqlite3
EOF

      run_command_and_stop("rake db:migrate")

      expect("db/bar.sqlite3").to be_an_existing_file
    end

    it "happens before application configuration" do
      insert_into_file_after("config/application.rb", /< Rails::Application$/, <<-EOL)
    config.foo = ENV["foo"]
EOL

      run_command_and_stop("rails runner 'puts Rails.application.config.foo'")

      expect(all_stdout).to include("bar")
    end
  end
end
