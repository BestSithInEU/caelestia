# Docker Configuration and Aliases

# Docker aliases
alias d 'docker'
alias dc 'docker compose'
alias dce 'docker compose exec'
alias dcl 'docker compose logs'
alias dclf 'docker compose logs -f'
alias dcp 'docker compose ps'
alias dcr 'docker compose run'
alias dcu 'docker compose up'
alias dcud 'docker compose up -d'
alias dcd 'docker compose down'
alias dcb 'docker compose build'
alias dcpull 'docker compose pull'
alias dcrestart 'docker compose restart'
alias dcstop 'docker compose stop'
alias dcstart 'docker compose start'

# Docker container aliases
alias dps 'docker ps'
alias dpsa 'docker ps -a'
alias dexec 'docker exec -it'
alias dlogs 'docker logs'
alias dlogsf 'docker logs -f'
alias dstop 'docker stop'
alias dstart 'docker start'
alias drestart 'docker restart'
alias drm 'docker rm'
alias drmf 'docker rm -f'
alias dtop 'docker top'
alias dstats 'docker stats'
alias dinspect 'docker inspect'
alias dport 'docker port'

# Docker image aliases
alias di 'docker images'
alias dpull 'docker pull'
alias dpush 'docker push'
alias dbuild 'docker build'
alias dtag 'docker tag'
alias drmi 'docker rmi'
alias drmif 'docker rmi -f'
alias dsearch 'docker search'
alias dhistory 'docker history'

# Docker volume aliases
alias dv 'docker volume'
alias dvls 'docker volume ls'
alias dvcreate 'docker volume create'
alias dvrm 'docker volume rm'
alias dvinspect 'docker volume inspect'
alias dvprune 'docker volume prune'

# Docker network aliases
alias dn 'docker network'
alias dnls 'docker network ls'
alias dncreate 'docker network create'
alias dnrm 'docker network rm'
alias dninspect 'docker network inspect'
alias dnprune 'docker network prune'

# Docker system aliases
alias dsys 'docker system'
alias ddf 'docker system df'
alias dprune 'docker system prune'
alias dprunea 'docker system prune -a'
alias dinfo 'docker info'
alias dversion 'docker version'

# Docker functions
function dsh
    if test (count $argv) -eq 0
        echo "Usage: dsh <container_name_or_id> [shell]"
        return 1
    end
    
    set -l shell "sh"
    if test (count $argv) -ge 2
        set shell $argv[2]
    end
    
    docker exec -it $argv[1] $shell
end

function dbash
    if test (count $argv) -eq 0
        echo "Usage: dbash <container_name_or_id>"
        return 1
    end
    docker exec -it $argv[1] bash
end

function dsh-last
    set -l container (docker ps -lq)
    if test -z "$container"
        echo "No running containers"
        return 1
    end
    docker exec -it $container sh
end

function dclean
    echo "Cleaning stopped containers..."
    docker container prune -f
    echo "Cleaning unused images..."
    docker image prune -f
    echo "Cleaning unused volumes..."
    docker volume prune -f
    echo "Cleaning unused networks..."
    docker network prune -f
end

function dcleanall
    echo "WARNING: This will remove all containers, images, volumes, and networks!"
    read -P "Are you sure? (y/N) " -n 1 response
    if test "$response" = "y" -o "$response" = "Y"
        docker stop (docker ps -aq) 2>/dev/null
        docker rm (docker ps -aq) 2>/dev/null
        docker rmi (docker images -q) 2>/dev/null
        docker volume rm (docker volume ls -q) 2>/dev/null
        docker network rm (docker network ls -q) 2>/dev/null
        echo "Docker cleanup complete"
    else
        echo "Cleanup cancelled"
    end
end

function dip
    if test (count $argv) -eq 0
        docker ps -q | xargs -I {} docker inspect -f '{{.Name}} - {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' {}
    else
        docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $argv[1]
    end
end

function dstopall
    set -l containers (docker ps -q)
    if test -z "$containers"
        echo "No running containers"
    else
        docker stop $containers
    end
end

function drmall
    set -l containers (docker ps -aq)
    if test -z "$containers"
        echo "No containers to remove"
    else
        docker rm $containers
    end
end

function drmiall
    set -l images (docker images -q)
    if test -z "$images"
        echo "No images to remove"
    else
        docker rmi $images
    end
end

function dlast
    docker ps -l
end

function dsize
    docker ps -s
end

function denv
    if test (count $argv) -eq 0
        echo "Usage: denv <container_name_or_id>"
        return 1
    end
    docker exec $argv[1] env
end

function dcup
    if test -f docker-compose.yml -o -f docker-compose.yaml -o -f compose.yml -o -f compose.yaml
        docker compose up -d
        docker compose logs -f
    else
        echo "No docker-compose file found"
    end
end

function dcdown
    if test -f docker-compose.yml -o -f docker-compose.yaml -o -f compose.yml -o -f compose.yaml
        docker compose down
    else
        echo "No docker-compose file found"
    end
end

function dcreup
    if test -f docker-compose.yml -o -f docker-compose.yaml -o -f compose.yml -o -f compose.yaml
        docker compose down
        docker compose up -d --build
        docker compose logs -f
    else
        echo "No docker-compose file found"
    end
end

# Docker buildx aliases
alias dbx 'docker buildx'
alias dbxb 'docker buildx build'
alias dbxls 'docker buildx ls'
alias dbxcreate 'docker buildx create'
alias dbxrm 'docker buildx rm'
alias dbxuse 'docker buildx use'
alias dbxinspect 'docker buildx inspect'

# Container registry aliases
function dpushreg
    if test (count $argv) -lt 2
        echo "Usage: dpushreg <image> <registry>"
        return 1
    end
    docker tag $argv[1] $argv[2]/$argv[1]
    docker push $argv[2]/$argv[1]
end

# Docker stats with better formatting
function dstats-nice
    docker stats --format "table {{.Container}}\t{{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
end

# Watch docker ps
function dwatch
    watch -n 2 docker ps
end