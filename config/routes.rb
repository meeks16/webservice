WebService::Application.routes.draw do

get 'sample' => 'temps#sample'

get 'helpbasic' => 'temps#helpbasic'

get 'help' => 'temps#help'

end
