{
  "properties" : { },
  "id" : "9332a2b638d74750a9f7a140ecd71e84",
  "script" : null,
  "groupId" : "ad31382a59c14517aa736c91dbdde8b0",
  "name" : "1.2.2查询数量",
  "createTime" : 1787823279270,
  "updateTime" : 1787888556537,
  "lock" : null,
  "createBy" : null,
  "updateBy" : "admin",
  "path" : "/count",
  "method" : "GET",
  "parameters" : [ ],
  "options" : [ ],
  "requestBody" : "",
  "headers" : [ ],
  "paths" : [ ],
  "responseBody" : "{\n    \"code\": 1,\n    \"message\": \"success\",\n    \"data\": 6,\n    \"timestamp\": 1787888554787,\n    \"executeTime\": 26\n}",
  "description" : null,
  "requestBodyDefinition" : null,
  "responseBodyDefinition" : null
}
================================
return db.mysql.selectInt('select count(*) from user')