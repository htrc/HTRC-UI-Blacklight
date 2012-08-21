BlacklightHtrc::Application.routes.draw do
  my_draw = Proc.new do
    resources :catalog, :only => [:index, :show, :update], :id => %r([^/;,?]+)
    resources :folder, :only => [:index, :show, :update, :destroy], :id => %r([^/;,?]+)

    root :to => "catalog#index"
  
    Blacklight.add_routes(self)
    
    # Add support for select_all routes
    resources :select_all, :only => [:index, :update], :as => "select_all"
    match "select_all/clear", :to => "select_all#clear"

    # Add support for export to registry
    #resources :registry, :only => [:export]
    #match "registry/export", :to => "registry#export"
  
    devise_for :users
  
    # The priority is based upon order of creation:
    # first created -> highest priority.
  
    # Sample of regular route:
    #   match 'products/:id' => 'catalog#view'
    # Keep in mind you can assign values other than :controller and :action
  
    # Sample of named route:
    #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
    # This route can be invoked with purchase_url(:id => product.id)
  
    # Sample resource route (maps HTTP verbs to controller actions automatically):
    #   resources :products
  
    # Sample resource route with options:
    #   resources :products do
    #     member do
    #       get 'short'
    #       post 'toggle'
    #     end
    #
    #     collection do
    #       get 'sold'
    #     end
    #   end
  
    # Sample resource route with sub-resources:
    #   resources :products do
    #     resources :comments, :sales
    #     resource :seller
    #   end
  
    # Sample resource route with more complex sub-resources
    #   resources :products do
    #     resources :comments
    #     resources :sales do
    #       get 'recent', :on => :collection
    #     end
    #   end
  
    # Sample resource route within a namespace:
    #   namespace :admin do
    #     # Directs /admin/products/* to Admin::ProductsController
    #     # (app/controllers/admin/products_controller.rb)
    #     resources :products
    #   end
  
    # You can have the root of your site routed with "root"
    # just remember to delete public/index.html.
    # root :to => 'welcome#index'
  
    # See how all your routes lay out with "rake routes"
  
    # This is a legacy wild controller route that's not recommended for RESTful applications.
    # Note: This route will make all actions in every controller accessible via GET requests.
    # match ':controller(/:action(/:id))(.:format)'
  end

  if ENV['RAILS_RELATIVE_URL_ROOT']
    scope ENV['RAILS_RELATIVE_URL_ROOT'] do
      my_draw.call
    end
  else
    my_draw.call
  end
end
