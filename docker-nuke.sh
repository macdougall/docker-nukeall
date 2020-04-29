#!/bin/bash
# Gary MacDougall
# Destroy and cleanup anything related to Digsup docker.
echo 'Docker cleanup!'
echo 'Stopping all Docker processes and removing orphans.'
if [ -z "$RUNNING" ];
then
 echo 'No running processes.'
else
  echo 'Stop all running processes.'
  for n in $RUNNING; do
   docker kill $n;
   echo "Removing " $n
   docker rm $n;
  done
fi
# remove volumes folder.
echo 'Removing local Digsup Volume filesystem.'
# running
RUNNING=$(docker ps -q -f 'status=running')
if [ -z "$RUNNING" ];
then
 echo 'No running processes.'
else
  echo 'Stop all running processes.'
  for n in $RUNNING; do
   docker kill $n;
   echo "Removing " $n
   docker rm $n;
  done
fi
UNKNOWN=$(docker images -a | grep "^<none>" | awk '{print $3}')
if [ -z "$UNKNOWN" ];
then
 echo 'No unknown images.'
else
  echo 'Removing all unknown images.'
  for n in $UNKNOWN; do
   echo "Removing " $n
   docker rmi --force $n;
  done
fi
echo 'Removing all exited processes, dangling images and dangling volumes.'
# exited
EXITED=$(docker ps -q -f 'status=exited')
if [ -z "$EXITED" ];
then
 echo 'No exited processes.'
else
  echo 'Removing all exited images.'
  for n in $EXITED; do
   echo "Removing " $n
   docker rm $n;
  done
fi
# dangled
DANGLING=$(docker images -q -f "dangling=true")
if [ -z "$DANGLING" ];
then
 echo 'No dangling images.'
else
  echo 'Removing all dangling images.'
  for n in $DANGLING; do
    echo "Removing " $n
    docker rmi --force $n;
  done
fi

# dangled volumes
VOLUMES=$(docker volume ls -qf dangling=true)
if [ -z "$VOLUMES" ];
then
 echo 'No dangling volumes.'
else
  echo 'Removing all dangling volumes.'
  for n in $VOLUMES; do
   echo "Removing " $n
   docker volume rm --force $n;
  done
fi
echo 'Done.'

# now let's do a prune to clear everything out and be sure
echo 'Doing a complete prune including volumes.'
echo 'WARNING: Answering yes will remove ALL your local Docker images.'
docker system prune -a --volumes
echo 'Completed.'
