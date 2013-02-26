#echo "Pruning attributes in static environment"
#knife environment from file "./environments/static.json" > /dev/null

knife exec -E '

res = search(:node, "name:java*")
name_list = map { |n| n.name } res
vagrant_list = map { |n| n.name.match("java-([a-z]+)-.+") } res

do
  Chef::Log.info( %Q(Deleting client, node and vagrant instance [#{name_list}]) )

## Delete the Node
   dn = Chef::Knife::NodeDelete.new()
   dn.name_args = name_list
   dn.run
 
## Delete the client
   dc = Chef::Knife::ClientDelete.new
   dc.name_args = name_list
   dc.run    

   `vagrant destroy #{vagrant_list} --force`
   
    env = environments.new("static")
    env.override_attr.delete("apps")
end

'