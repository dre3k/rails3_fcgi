Rails3Fcgi::Application.routes.draw do
  my_draw = Proc.new do
    resources :entities
    root :to => "entities#index"
  end

  if ENV['RAILS_RELATIVE_URL_ROOT']
    scope ENV['RAILS_RELATIVE_URL_ROOT'] do
      my_draw.call
    end
  else
    my_draw.call
  end
end
