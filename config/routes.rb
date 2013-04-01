ActionController::Routing::Routes.draw do |map|

  map.biz '/biz3795', :controller => 'sessions', :action => 'biz_new'
  map.create_biz '/create_biz', :controller => 'sessions', :action => 'create_biz'
  map.biz_dashboard '/biz_dashboard', :controller => 'users', :action => 'biz_dashboard'

  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.profile '/profile/:id',:controller => 'users',:action=>'consumer_profile'
  map.profile_create '/create_profile/:id',:controller => 'users',:action=>'create_consumer_profile'
  map.user_account '/user_account/:id',:controller => 'users',:action=>'user_account'
  map.show_account '/show_account/:id/:type',:controller=>"users",:actions=>"show_account"
  map.biz_show_account '/biz_show_account/:id',:controller=>"users",:actions=>"biz_show_account"
  map.create_user_account '/create_user_account/:id',:controller => 'users',:action=>'create_user_account'
  map.forgot '/forgot', :controller => 'users', :action => 'forgot'
  map.about '/about', :controller => 'home', :action => 'about'
  map.privacy '/privacy', :controller => 'home', :action => 'privacy'
  map.rights '/rights', :controller => 'home', :action => 'rights'

  map.delete_debt '/debt/:id', :controller => 'users', :action => 'delete_debt'
  
  map.how '/how', :controller => 'home', :action => 'how'
  map.help '/help', :controller => 'home', :action => 'help'
  map.terms '/terms', :controller => 'home', :action => 'terms'
  map.faq '/faq', :controller => 'home', :action => 'faq'
  map.forgot '/forgot', :controller => 'users', :action => 'forgot'
  map.pending '/pending', :controller => 'users', :action => 'pending_offers'
  map.biz_pending '/biz/pending', :controller => 'users', :action => 'biz_pending_offer'
  map.biz_accepted '/biz/accepted', :controller => 'users', :action => 'biz_accepted_offers'
  
  map.notify '/notify',:controller=>"users",:action => "notify"
  map.success '/success/:id',:controller=>"users",:action => "success_return"
  map.cancel_return '/cancel_return/:id',:controller=>"users",:action => "cancel_return"
   

  map.payment '/payment/:id', :controller => 'users', :action => 'payment'
  map.schedule '/schedule/:id', :controller => 'users', :action => 'schedule'
  

  map.debts '/debts', :controller => 'home', :action => 'fill_debts'
  map.agreements '/agreements', :controller => 'home', :action => 'my_agreements'
  map.statistics '/statistics', :controller => 'home', :action => 'my_statistics'
  map.biz_statistics '/biz/statistics', :controller => 'users', :action => 'biz_statistics'
  map.negotiate '/negotiate', :controller => 'users', :action => 'negotiate'
  map.biz_negotiate '/biz_negotiate', :controller => 'users', :action => 'biz_negotiate'
  #map.home '/home', :controller => "home",:action => "index"
  map.root :controller => "home",:action => "index"
  map.resources :users

  map.resource :session


  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
