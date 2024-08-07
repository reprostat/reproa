docker run -ti --rm \
	--user $(id -u):$(id -g) --env="DISPLAY" --env="HOME" --env="XDG_RUNTIME_DIR" --volume="$HOME:$HOME:rw" --volume="/dev:/dev:ro" --volume="${XDG_RUNTIME_DIR}:${XDG_RUNTIME_DIR}:rw" \
	--network=host \
    --volume=/ceph/users/usq33871/data/ds114_test1:/data \
    --volume=/ceph/users/usq33871/projects/test_docker:/outputs \
	--volume=/ceph/users/usq33871/projects/reproa/tests:/config \
	reproa:dev /data /outputs participant --participant_label 01,02 --config /config/ds114_test1.xml,/config/ds114_test1.m --skip_bids_validator