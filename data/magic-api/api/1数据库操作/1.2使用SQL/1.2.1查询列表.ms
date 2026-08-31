{
  "properties" : { },
  "id" : "3025c9bee12e4f8e98831e4efc2d304b",
  "script" : null,
  "groupId" : "ad31382a59c14517aa736c91dbdde8b0",
  "name" : "1.2.1查询列表",
  "createTime" : 1787823279266,
  "updateTime" : 1787888532367,
  "lock" : null,
  "createBy" : null,
  "updateBy" : "admin",
  "path" : "/list",
  "method" : "GET",
  "parameters" : [ ],
  "options" : [ ],
  "requestBody" : "",
  "headers" : [ ],
  "paths" : [ ],
  "responseBody" : "{\n    \"code\": 1,\n    \"message\": \"success\",\n    \"data\": [\n        {\n            \"User\": \"magic\"\n        },\n        {\n            \"User\": \"root\"\n        },\n        {\n            \"User\": \"mysql.infoschema\"\n        },\n        {\n            \"User\": \"mysql.session\"\n        },\n        {\n            \"User\": \"mysql.sys\"\n        },\n        {\n            \"User\": \"root\"\n        }\n    ],\n    \"timestamp\": 1787888517858,\n    \"executeTime\": 38\n}",
  "description" : null,
  "requestBodyDefinition" : null,
  "responseBodyDefinition" : null
}
================================
return db.mysql.select('select User from user')
