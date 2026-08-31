{
  "properties" : { },
  "id" : "f34e97caaa0441acb396fa1eed3ac0da",
  "script" : null,
  "groupId" : "c851c185b0374b6ba5ae9ddd323e1ff8",
  "name" : "2.1http模块",
  "createTime" : 1787823279327,
  "updateTime" : 1787904442005,
  "lock" : null,
  "createBy" : null,
  "updateBy" : "admin",
  "path" : "/http",
  "method" : "GET",
  "parameters" : [ ],
  "options" : [ ],
  "requestBody" : "",
  "headers" : [ ],
  "paths" : [ ],
  "responseBody" : "{\n    \"code\": 1,\n    \"message\": \"success\",\n    \"data\": {},\n    \"timestamp\": 1787904429504,\n    \"executeTime\": 3\n}",
  "description" : null,
  "requestBodyDefinition" : null,
  "responseBodyDefinition" : null
}
================================
import http;
// 相关文档： https://www.ssssssss.org/magic-api/pages/module/http/
return http.connect('http://10.0.0.22:8889/db/module/count')
    .get()
    .getBody()