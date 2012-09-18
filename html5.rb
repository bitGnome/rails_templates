# RVM
current_ruby = %x{rvm list}.match(/\=\*\s(.*)\s\[/)[1].strip
run "rvm gemset create #{app_name}"
run "rvm #{current_ruby}@#{app_name} gem install bundler"
run "rvm #{current_ruby}@#{app_name} -S bundle install"

file ".rvmrc", <<-END
rvm use #{current_ruby}@#{app_name}
END

gem("haml-rails")
gem("twitter-bootstrap-rails")
generate("bootstrap:install")

layout_type = ask("What type of bootstrap layout would you like? (fixed | fluid)")

case layout_type.downcase
  when "fixed"
    say("Setting the layout to fixed!")
    generate("bootstrap:layout application fixed")
    run "rm app/views/layouts/application.html.erb"
    
  when "fluid"
    say("Setting the layout to fluid!")
    generate("bootstrap:layout application fluid")
    run "rm app/views/layouts/application.html.erb"
    
  else
    say("The layout was not bootstraped!")
  end

gem("simple_form")
generate("simple_form:install --bootstrap")

gem("font-awesome-sass-rails", :group  => "assets" )

run "bundle"

if yes?("Would you like create initial Scaffolding? (yes|no)")
  name = ask("Name of the scaffolding: ")
  params = ask("Parameters: ")
  
  stylesheet_options = ""
  
  if yes?("Would you like to add a bootstrap theme to the controller? (yes|no)")
    controller_name = ask("Controller name to theme:")
    bootstrap_theme = true
    stylesheet_options = "--no-stylesheets"
  end
  
  generate(:scaffold, "#{name} #{params} #{stylesheet_options}")
  rake("db:migrate")
  
  if bootstrap_theme
    generate("bootstrap:themed #{controller_name} -f")
  end
  
  if yes?("Add a root route ?")
    
    new_root_route = ask("Name of controller for default route:")
    
    if yes?("#{new_root_route}#index will be used for new route? (yes|no)")
      route "root :to => '#{new_root_route}#index'"
      run "rm public/index.html"
    else
      say("New route was not added!")
    end
  end
  
end
  
git :init
git :add  => "."
git :commit  => "-m 'Initial Commit!'"