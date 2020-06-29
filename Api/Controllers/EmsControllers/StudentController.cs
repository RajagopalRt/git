using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using EmsApi.DAL;
using EmsApi.Models.EMS;

namespace EmsApi.Controllers.EmsControllers
{
    public class StudentController : ApiController
    {
        [HttpPost]
        public HttpResponseMessage SaveStudent(SaveStudentDTO obj)
        {
            HttpResponseMessage message;
            try
            {
                StudentDAL dal = new StudentDAL();
                var dynobj = new { result = dal.SaveStudent(obj) };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }

        [HttpPost]
        public HttpResponseMessage ModifyStudent(ModifyStudentDTO obj)
        {
            HttpResponseMessage message;
            try
            {
                StudentDAL dal = new StudentDAL();
                var dynobj = new { result = dal.ModifyStudent(obj) };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
        [HttpPost]
        public HttpResponseMessage RemoveStudent(RemoveStudentDTO obj)
        {
            HttpResponseMessage message;
            try
            {
                StudentDAL dal = new StudentDAL();
                var dynobj = new { result = dal.RemoveStudent(obj) };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
        [HttpPost]
        public HttpResponseMessage SelectStudent()
        {
            HttpResponseMessage message;
            try
            {
                StudentDAL dal = new StudentDAL();
                var dynobj = new { result = dal.SelectStudent() };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
        [HttpPost]
        public HttpResponseMessage SectionName()
        {
            HttpResponseMessage message;
            try
            {
                StudentDAL dal = new StudentDAL();
                var dynobj = new { result = dal.SectionName() };
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
