#!/bin/zsh

CONTAINER="scouter_question_1"

docker exec ${CONTAINER} \
    ./vendor/bin/phpcs --standard=phpcs.xml --extensions=php .

TEST_RESULT=`docker exec ${CONTAINER} echo $?`

if [ $TEST_RESULT == 0 ]; then
    echo '0'
else
    echo '1'
fi
