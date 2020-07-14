start_torchserve()
{
  echo "Starting TorchServe"
  torchserve --start --model-store model_store &
  pid=$!
  count=$(ps -A| grep $pid |wc -l)
  if [[ $count -eq 1 ]]
  then
          if wait $pid; then
                  echo "Successfully started TorchServe"
          else
                  echo "TorchServe start failed (returned $?)"
                  exit 1
          fi
  else
          echo "Successfully started TorchServe"
  fi

  sleep 10
}

stop_torchserve()
{
  torchserve --stop
  sleep 10
}

register_model()
{
  echo "Registering $1 model"
  response=$(curl --write-out %{http_code} --silent --output /dev/null --retry 5 -X POST "http://localhost:8081/models?url=https://torchserve.s3.amazonaws.com/mar_files/$1.mar&initial_workers=1&synchronous=true")

  if [ ! "$response" == 200 ]
  then
      echo "Failed to register model with torchserve"
      cleanup
      exit 1
  else
      echo "Successfully registered $1 model with torchserve"
  fi
}

unregister_model()
{
  echo "Unregistering $1 model"
  response=$(curl --write-out %{http_code} --silent --output /dev/null --retry 5 -X DELETE "http://localhost:8081/models/$1")

  if [ ! "$response" == 200 ]
  then
      echo "Failed to register $1 model with torchserve"
      cleanup
      exit 1
  else
      echo "Successfully registered $1 model with torchserve"
  fi
}

run_inference()
{
  for i in {1..4}
  do
    echo "Running inference on $1 model"
    response=$(curl --write-out %{http_code} --silent --output /dev/null --retry 5 -X POST http://localhost:8080/predictions/$1 -T $2)

    if [ ! "$response" == 200 ]
    then
        echo "Failed to run inference on $1 model"
        cleanup
        exit 1
    else
        echo "Successfully ran infernece on $1 model."
    fi
  done
}

cleanup()
{
  stop_torchserve

  rm -rf model_store

  rm -rf logs
}

mkdir model_store

start_torchserve


MODELS=("fastrcnn" "fcn_resnet_101" "my_text_classifier" "resnet-18")
MODEL_INPUTS=("examples/object_detector/persons.jpg" "examples/image_segmenter/fcn/persons.jpg" "examples/text_classification/sample_text.txt" "examples/image_classifier/kitten.jpg")
HANDLERS=("object_detector" "image_segmenter" "text_classification" "image_classifier")

for i in ${!MODELS[@]};
do
  model=${MODELS[$i]}
  input=${MODEL_INPUTS[$i]}
  handler=${HANDLERS[$i]}
  register_model "$model"
  run_inference "$model" "$input"
  #skip unregistering resnet-18 model to test snapshot feature with restart
  if [ "$model" != "resnet-18" ]
  then
    unregister_model "$model"
  fi
  echo "$handler default handler is stable."
done

stop_torchserve

# restarting torchserve
# this should restart with the generated snapshot and resnet-18 model should be automatically registered

start_torchserve

run_inference resnet-18 examples/image_classifier/kitten.jpg

stop_torchserve

cleanup

echo "CONGRATULATIONS!!! YOUR BRANCH IS IN STABLE STATE"