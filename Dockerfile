FROM python:3.7-alpine
LABEL Adrián González

# Ensures that the python output is sent straight to terminal
ENV PYTHONUNBUFFERED 1

# # Copy requirements in docker image
COPY ./requirements.txt /requirements.txt

# Postgres libraries with minimun extra dependencies so packages in requirements dont fail
RUN apk add --update --no-cache postgresql-client jpeg-dev
RUN apk add --update --no-cache --virtual .tmp-build-deps \
    gcc libc-dev linux-headers postgresql-dev musl-dev zlib zlib-dev
RUN pip install -r /requirements.txt

# Afer requirements installation we can delete the temporary requirements
RUN apk del .tmp-build-deps

# Create an empty folder in our docker container and switches this folder as default location
# Copies the project to the default docker folder
RUN mkdir /app
WORKDIR /app
COPY ./app /app

# Folders to save media and static files
# with -p we create the parent folder if doesn't exists
RUN mkdir -p /vol/web/media
RUN mkdir -p /vol/web/static

# Create a user that is going to be used to run applications only
# Security propuses an avoid docker run processes with root privileges
RUN adduser -D user

# Give permission to user 'user' over vol folder
# We have to do this first with root user before switch to 'user'
# -R stands for recursive
RUN chown -R user:user /vol/
RUN chmod -R 755 /vol/web

# Change to 'user' User
USER user
