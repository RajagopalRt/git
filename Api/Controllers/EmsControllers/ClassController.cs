using EmsApi.DAL;
using EmsApi.Models.EMS;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace EmsApi.Controllers.EmsControllers
{
    public class ClassController : ApiController
    {
        [HttpPost]
        public HttpResponseMessage SaveClass(SaveClassDTO obj)
        {
            HttpResponseMessage message;
            try
            {
                ClassDAL dal = new ClassDAL();
                var dynobj = new { result = dal.SaveClass(obj) };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
        [HttpPost]
        public HttpResponseMessage ModifyClass(ModifyClassDTO obj)
        {
            HttpResponseMessage message;
            try
            {
                ClassDAL dal = new ClassDAL();
                var dynobj = new { result = dal.ModifyClass(obj) };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
        [HttpPost]
        public HttpResponseMessage RemoveClass(RemoveClassDTO obj)
        {
            HttpResponseMessage message;
            try
            {
                ClassDAL dal = new ClassDAL();
                var dynobj = new { result = dal.RemoveClass(obj) };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
        [HttpPost]
        public HttpResponseMessage SelectClass()
        {
            HttpResponseMessage message;
            try
            {
                ClassDAL dal = new ClassDAL();
                var dynobj = new { result = dal.SelectClass() };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
        [HttpPost]
        public HttpResponseMessage SelectDepartmentName()
        {
            HttpResponseMessage message;
            try
            {
                ClassDAL dal = new ClassDAL();
                var dynobj = new { result = dal.SelectDepartmentName() };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
    }
}
