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
    public class EmployeeController : ApiController
    {
        [HttpPost]
        public HttpResponseMessage SaveEmployee(SaveEmployeeDTO obj)
        {
            HttpResponseMessage message;
            try
            {
                EmployeeDAL dal = new EmployeeDAL();
                var dynobj = new { result = dal.SaveEmployee(obj) };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
        [HttpPost]
        public HttpResponseMessage ModifyEmployee(ModifyEmployeeDTO obj)
        {
            HttpResponseMessage message;
            try
            {
                EmployeeDAL dal = new EmployeeDAL();
                var dynobj = new { result = dal.ModifyEmployee(obj) };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
        [HttpPost]
        public HttpResponseMessage RemoveEmployee(RemoveEmployeeDTO obj)
        {
            HttpResponseMessage message;
            try
            {
                EmployeeDAL dal = new EmployeeDAL();
                var dynobj = new { result = dal.RemoveEmployee(obj) };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
        [HttpPost]
        public HttpResponseMessage SelectEmployee()
        {
            HttpResponseMessage message;
            try
            {
                EmployeeDAL dal = new EmployeeDAL();
                var dynobj = new { result = dal.SelectEmployee() };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
        [HttpPost]
        public HttpResponseMessage RoleName()
        {
            HttpResponseMessage message;
            try
            {
                EmployeeDAL dal = new EmployeeDAL();
                var dynobj = new { result = dal.RoleName() };
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
