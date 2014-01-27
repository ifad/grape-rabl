object :@user
attributes :name, :email

child :@project do
  attributes :name
end
