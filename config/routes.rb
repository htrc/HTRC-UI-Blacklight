BlacklightHtrc::Application.routes.draw do

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  devise_scope :user do
    get 'sign_in', :to => 'devise/sessions#new', :as => :new_user_session
    get 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  #as :user do
  #  get 'blacklight/signin' => 'devise/sessions#new', :as => :new_user_session
  #  post 'blacklight/signin' => 'devise/sessions#create', :as => :user_session
  #  get 'blacklight/signout' => 'devise/sessions#destroy', :as => :destroy_user_session
  #  delete 'blacklight/signout' => 'devise/sessions#destroy', :as => :destroy_user_session
  #end

  my_draw = Proc.new do
    #fix problem with facet route not working...there may be other problems with routes with /
    match "catalog/facet/:id", :to => 'catalog#facet', :as => 'catalog_facet'
    #this is indented to support routes with . and /
    resources :catalog, :only => [:index, :show, :update], :id => %r([^;,?]+)
    # resources :folder, :only => [:index, :show, :update, :destroy], :id => %r([^;,?]+)
    resources :folder, :only => [:index, :update, :destroy], :id => %r([^;,?]+)

    #default blacklight statements - should this be first?
    root :to => "catalog#index"
    Blacklight.add_routes(self)

    # Add support for folder (i.e. collection) item gathering
    match "folder/update/all_search", :to => "folder#update_all_search", :as => "folder_update_all_search"
    match "folder/update/page", :to => "folder#update_page", :as => "folder_update_page"
    match "folder/clear/all_search", :to => "folder#clear_all_search", :as => "folder_clear_all_search"
    match "folder/clear/page", :to => "folder#clear_page", :as => "folder_clear_page"
    match "folder/clear", :to => "folder#clear", :as => "clear_folder"

    # Add support for select_all routes
    resources :select_all, :only => [:index, :update], :as => "select_all"
    match "select_all/clear", :to => "select_all#clear"

    # Add support for export to registry
    resources :registry, :only => [:index, :export, :load, :manage, :remove]
    match "registry/export", :to => "registry#export", :as => "registry_export"
    match "registry/manage", :to => "registry#manage", :as => "registry_manage"
    match "registry/load", :to => "registry#load", :as => "registry_load"
    match "registry/remove", :to => "registry#remove", :as => "registry_remove"

    match "folder/clear", :to => "folder#clear", :as => "clear_folder"
  
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
