export $(cat .env) > /dev/null 2>&1; 
docker --config config stack deploy --compose-file docker-compose.yml app-prod --with-registry-auth --detach=false

sleep 5

FAILED_SERVICES=$(docker service ls --filter "desired-state=running" --format '{{.Name}} {{.Replicas}}' | awk '$2 ~ /0\// {print $1}')

if [ -n "$FAILED_SERVICES" ]; then
    echo
    echo "⚠️  Deployment finished with issues in the following services:"
    echo "$FAILED_SERVICES"
    echo "You may need to check logs or fix manually:"
    for svc in $FAILED_SERVICES; do
        echo "---- Logs for $svc ----"
        docker service logs --tail 20 "$svc"
        echo "----------------------"
    done
else
    echo
    echo "✅ All services deployed successfully and running."
fi