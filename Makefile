include .env

TAG = local:$(IMG_NAME)
REPO_REMOTE = $(REPO_OWNER)/$(IMG_NAME)
TAG_REMOTE = $(REPO_REMOTE):$(IMG_VERSION)
CNAME = $(IMG_NAME) 

PROD_COMPOSE_FILE=docker-compose-prod.yml

test:
	coverage run manage.py test bmbhelper -v 2

serve: open
	python manage.py runserver

shell:
	python manage.py shell

open:
	open http://localhost:$(PORT)/$(APP_URI)

freeze:
	pip freeze > requirements.txt
	git add requirements.txt

merge: test freeze
	git commit
	git push dev
	git checkout master
	git merge dev
	git push master

## pre git section
precommit: test freeze

prod-deploy-secrets:



### DOCKER SECTION ###

remake: rebuild 
rebuild: rm-container rm-image build

rm-container: stop-container
	docker rm $(CNAME) || true

rm-image: rm-container
	docker image rm $(TAG) || true

stop-container:
	docker stop $(CNAME) || true

build:
	docker build --tag $(TAG) .

image-push-remote: remake image-add-remote-tag
	docker image push $(TAG_REMOTE)

image-add-remote-tag:
	docker image tag $(TAG) $(TAG_REMOTE)

comp-build-up: comp-build comp-up

comp-build:
	docker-compose build 

comp-up:
	docker-compose up -d

comp-logs:
	docker-compose logs -f

prod-full-build: prod-comp-conf prod-comp-build prod-comp-up prod-comp-logs

prod-comp-up:
	docker-compose --file=$(PROD_COMPOSE_FILE) up -d

prod-comp-build:
	docker-compose --file=$(PROD_COMPOSE_FILE) build 

prod-comp-rr:
	docker-compose --file=$(PROD_COMPOSE_FILE) restart

prod-comp-conf:
	docker-compose --file=$(PROD_COMPOSE_FILE) config

prod-comp-logs:
	docker-compose --file=$(PROD_COMPOSE_FILE) logs -f
