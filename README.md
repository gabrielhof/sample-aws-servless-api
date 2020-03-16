# sample-aws-servless-api

This is just a sample project used by me for learning how to use:

- AWS API Gateway
- AWS Lambda
- Terraform

## Requirements:

- Node.JS and NPM
- Terraform

## Setting up AWS

Install the Node.JS dependencies:

```
npm install
```

Zip the lambdas using:

```
npm run zip
```

Then execute terraform:

```
terraform apply
```

Terraform will ask for your AWS account ID. After inserting it, you can go to AWS and deploy the API manually.

## Consuming the API

### GET /movies

Returns a list of movies in the following format:

```json
[
  {
    "id": "b973b68e-83e2-4ad6-9bce-c3fe025168f2",
    "name": "The Dark Knight Rises",
    "year": 2012,
    "director": "Christopher Nolan"
  }
]
```

### POST /movies

Creates a movie. You need to inform the following JSON body:

```json
{
  "name": "The Dark Knight Rises",
  "year": 2012,
  "director": "Christopher Nolan"
}
```

The API will return you the movie object with it's generated ID:

```json
{
  "id": "b973b68e-83e2-4ad6-9bce-c3fe025168f2",
  "name": "The Dark Knight Rises",
  "year": 2012,
  "director": "Christopher Nolan"
}
```
