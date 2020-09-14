##
## Protobuf
##

init_protobuf:
	git submodule init

update_protobuf:
	git submodule update

##
## For production env
##

#
# Manage prod env (in local)
#

build_prod_env: init_protobuf update_protobuf
	./docker/build.sh
