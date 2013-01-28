WebService::Application.routes.draw do

  resources :trends


  resources :videos


get 'sample' => 'temps#sample'

end
