object :@project
attributes :name

node :info do |project|
  partial "partial", object: project.type
end

child(:author, partial: 'info')
