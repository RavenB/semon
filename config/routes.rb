Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'campaigns#index'

  resources :campaigns, :tags, :categories

  scope '/campaigns' do
    get '/:id/tags' => 'tags#index'
    resources :messages, path: '/:id/messages'
  end

  delete '/messages/:id' => 'messages#destroy'

  scope '/dashboard' do
    get '/:id/messages_in_period' => 'dashboard#messages_in_period'
    get '/:id/messages_at_time' => 'dashboard#messages_at_time'
    get '/:id/origin' => 'dashboard#origin'
    get '/:id/sentiment' => 'dashboard#sentiment'
    get '/:id/top_tags' => 'dashboard#top_tags'
    get '/:id/word_cloud' => 'dashboard#word_cloud'
    get '/:id/word_tree' => 'dashboard#word_tree'
    get '/:id/top_authors' => 'dashboard#top_authors'
    get '/:id/author_genders' => 'dashboard#author_genders'
  end

  get '/template/tag_edit_list_item' => 'tags#tag_edit_list_item'
  get '/tweets/:id' => 'twitter#tweets'
  get '/instagrams/:id' => 'instagram#instagrams'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
