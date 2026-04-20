# wrapper script example
#

source ./.env.sh
source ./.env.<app-name>.sh

# creating local gzipped snapshot of db
./create-db-snapshot.sh

# syncing it to remote s3 bucket
./sync-db-snapshots.sh

# syncing user uploads bucket with remote
./sync-s3-bucket.sh
