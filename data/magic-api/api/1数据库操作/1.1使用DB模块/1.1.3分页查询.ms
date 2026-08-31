{
  "properties" : { },
  "id" : "0e285f3414ae43cab0ec53adc20013c6",
  "script" : null,
  "groupId" : "8350c5f638d9400fa9c44f46412bba31",
  "name" : "1.1.3分页查询",
  "createTime" : 1787823279240,
  "updateTime" : 1787903842737,
  "lock" : null,
  "createBy" : null,
  "updateBy" : "admin",
  "path" : "/page",
  "method" : "POST",
  "parameters" : [ {
    "name" : "page",
    "value" : "1",
    "description" : null,
    "required" : false,
    "dataType" : "String",
    "type" : null,
    "defaultValue" : null,
    "validateType" : null,
    "error" : null,
    "expression" : null,
    "children" : null
  }, {
    "name" : "size",
    "value" : "10",
    "description" : null,
    "required" : false,
    "dataType" : "String",
    "type" : null,
    "defaultValue" : null,
    "validateType" : null,
    "error" : null,
    "expression" : null,
    "children" : null
  } ],
  "options" : [ ],
  "requestBody" : "",
  "headers" : [ ],
  "paths" : [ ],
  "responseBody" : "{\n    \"code\": 1,\n    \"message\": \"success\",\n    \"data\": {\n        \"total\": 4,\n        \"list\": [\n            {\n                \"user\": \"user1\",\n                \"name\": \"name1\"\n            },\n            {\n                \"user\": \"user2\",\n                \"name\": \"name2\"\n            },\n            {\n                \"user\": \"root\",\n                \"name\": \"root\"\n            },\n            {\n                \"user\": \"magic\",\n                \"name\": \"magic\"\n            }\n        ]\n    },\n    \"timestamp\": 1787903644160,\n    \"executeTime\": 20\n}",
  "description" : null,
  "requestBodyDefinition" : null,
  "responseBodyDefinition" : {
    "name" : "",
    "value" : "",
    "description" : "",
    "required" : false,
    "dataType" : "Object",
    "type" : null,
    "defaultValue" : null,
    "validateType" : "",
    "error" : "",
    "expression" : "",
    "children" : [ {
      "name" : "code",
      "value" : "1",
      "description" : "",
      "required" : false,
      "dataType" : "Integer",
      "type" : null,
      "defaultValue" : null,
      "validateType" : "",
      "error" : "",
      "expression" : "",
      "children" : [ ]
    }, {
      "name" : "message",
      "value" : "success",
      "description" : "",
      "required" : false,
      "dataType" : "String",
      "type" : null,
      "defaultValue" : null,
      "validateType" : "",
      "error" : "",
      "expression" : "",
      "children" : [ ]
    }, {
      "name" : "data",
      "value" : "",
      "description" : "",
      "required" : false,
      "dataType" : "Object",
      "type" : null,
      "defaultValue" : null,
      "validateType" : "",
      "error" : "",
      "expression" : "",
      "children" : [ {
        "name" : "total",
        "value" : "4",
        "description" : "",
        "required" : false,
        "dataType" : "Integer",
        "type" : null,
        "defaultValue" : null,
        "validateType" : "",
        "error" : "",
        "expression" : "",
        "children" : [ ]
      }, {
        "name" : "list",
        "value" : "",
        "description" : "",
        "required" : false,
        "dataType" : "Array",
        "type" : null,
        "defaultValue" : null,
        "validateType" : "",
        "error" : "",
        "expression" : "",
        "children" : [ {
          "name" : "",
          "value" : "",
          "description" : "",
          "required" : false,
          "dataType" : "Object",
          "type" : null,
          "defaultValue" : null,
          "validateType" : "",
          "error" : "",
          "expression" : "",
          "children" : [ {
            "name" : "user",
            "value" : "user1",
            "description" : "",
            "required" : false,
            "dataType" : "String",
            "type" : null,
            "defaultValue" : null,
            "validateType" : "",
            "error" : "",
            "expression" : "",
            "children" : [ ]
          }, {
            "name" : "name",
            "value" : "name1",
            "description" : "",
            "required" : false,
            "dataType" : "String",
            "type" : null,
            "defaultValue" : null,
            "validateType" : "",
            "error" : "",
            "expression" : "",
            "children" : [ ]
          } ]
        } ]
      } ]
    }, {
      "name" : "timestamp",
      "value" : "1787903644160",
      "description" : "",
      "required" : false,
      "dataType" : "Long",
      "type" : null,
      "defaultValue" : null,
      "validateType" : "",
      "error" : "",
      "expression" : "",
      "children" : [ ]
    }, {
      "name" : "executeTime",
      "value" : "20",
      "description" : "",
      "required" : false,
      "dataType" : "Integer",
      "type" : null,
      "defaultValue" : null,
      "validateType" : "",
      "error" : "",
      "expression" : "",
      "children" : [ ]
    } ]
  }
}
================================
/**
 * 关于分页相关配置 
 * 配置文件：https://www.ssssssss.org/magic-api/pages/config/spring-boot/#page
 * 自定义分页参数获取： https://www.ssssssss.org/magic-api/pages/quick/page/#%E8%87%AA%E5%AE%9A%E4%B9%89%E5%88%86%E9%A1%B5%E5%8F%82%E6%95%B0%E8%8E%B7%E5%8F%96
 * 自定义分页结果：https://www.ssssssss.org/magic-api/pages/base/response/#%E6%9B%B4%E5%8A%A0%E7%81%B5%E6%B4%BB%E7%9A%84%E8%87%AA%E5%AE%9A%E4%B9%89%E7%BB%93%E6%9E%84%E9%85%8D%E7%BD%AE
 */

//post :http://10.0.0.22:8889/db/module/page?size=2&page=2  或者 json {"size": "2","page": "2"}
//get  :http://10.0.0.22:8889/db/module/page?size=2&page=2
return db.magic.table('user').columns('user','name').page();