# Python Skeleton for Micorservices

## Getting started

### Requirements

You need to install Docker in your machine if you haven't already [Docker](https://www.docker.com/)

### Development

Follow the next steps to set up the development environment in your machine.

1. Clone the repo and go to the folder

```ssh
git clone https://github.com/Vizzuality/python-skeleton
cd python-skeleton
```

2. Run the ms.sh shell script in development mode.

```ssh
./ps.sh develop
```

If this is the first time you run it, it may take a few minutes.

### Code structure

The API has been packed in a Python module (ps). It creates and exposes a WSGI application. The core functionality
has been divided in three different layers or submodules (Routes, Services and Models).

There are also some generic submodules that manage the request validations, HTTP errors and the background tasks manager.
