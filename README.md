## [Overview](#Overview)  |  [Doc](#Doc)  |  [Code Coverage](#Cov)  |  [Docker](#Docker) |  [Task Flow](#Tasks) 

   [Stores](#Stores)

   [Products](#Products)
  
   [Stock](#Stock)
   
# <a name="Overview"></a> Overview

This API as been design to be used to tests the Swift Perfect framework performances. 
This API is build to work with a PostgreSQL database and provide a way to interact with stores and products through an relational model.

# <a name="Doc"></a> Api Documentation



## <a name="Stores"></a> Stores

URL        :  ` api/v1/stores ` |  ` api/v1/stores/:id `

Method     :  ` GET `,` POST `  |  ` DELETE ` , ` PATCH ` ` GET `

URL Params :      none          |   id: required

Parameters :  ` Limit ` and ` Offet ` with GET  | None

Request body Structure : 
```Swift
// Store obj
{
   "refStore": String   //  Auto generated do not modify
   "name": String,      //  required
   "picture":String,    //  optional
   "vat":Double,        //  optional
   "currency":String,   //  optional
   "merchantkey":String //  optional
} 
```

Code 

#### Code: 200 OK

Content: 

```Swift
// Store obj
{
   "refStore": String   //  Auto generated do not modify
   "name": String,      //  required
   "picture":String,    //  optional
   "vat":Double,        //  optional
   "currency":String,   //  optional
   "merchantkey":String //  optional
} 
```
OR

```Swift
[
   {
      "refStore": String   //  Auto generated do not modify
      "name": String,      //  required
      "picture":String,    //  optional
      "vat":Double,        //  optional
      "currency":String,   //  optional
      "merchantkey":String //  optional
   },{
      "refStore": String   //  Auto generated do not modify
      "name": String,      //  required
      "picture":String,    //  optional
      "vat":Double,        //  optional
      "currency":String,   //  optional
      "merchantkey":String //  optional
   }
   ,...
] 
```

#### Code: 201 CREATED

Content: 
```Swift
// Store obj
{
   "refStore": String   //  Auto generated do not modify
   "name": String,      //  required
   "picture":String,    //  optional
   "vat":Double,        //  optional
   "currency":String,   //  optional
   "merchantkey":String //  optional
} 
```




### <a name="Products"></a> Products
### <a name="Stock"></a> Stock
### <a name="Error"></a> API Error

#### Code: 400 BAD REQUEST 

Example : 

- [x] Empty JSON Body for POST or PATCH
          
- [x] Missing required properties POST

- [x] Wrong limit or offset ( < 0 )

#### Code: 404 NOT FOUND 

Example : Id not found in database  

#### Code: 500 INTERNAL SERVER ERROR 


# <a name="Docker"></a> Work with Docker

First download required images :

```shell 
docker pull postgres
```
```shell 
docker pull swift
```

Launch database image : 

Build image : 

first go in the Docker file and update these lines :

```Dockerfile
ENV DATABASE_HOST=*host*  #provide your host name ( you can retrieve via docker inspect )
ENV DATABASE_PORT=*port*  #provide your host port ( postgres work often with 5432 )
ENV DATABASE_DB=*db name*
ENV DATABASE_USER=*user name*
ENV DATABASE_PASSWORD=*database password*
```
```shell 
docker build -t *name* . 
```

Launch your image link to database : 

```shell


```

# <a name="Cov"></a> Code Coverage

*Coming Soon* 

# <a name="Tasks"></a> Task Flow
- [x] Database connection
- [x] Stores routes
- [x] Products routes 
- [x] Stock routes 
- [x] Docker
- [x] Linux compatibility 
- [ ] API docs
- [ ] Unit tests 
- [ ] CI 
- [ ] Code Cov

