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
    public class DepartmentController : ApiController
    {
        [HttpPost]
        public HttpResponseMessage SaveDepartment(SaveDepartmentDTO obj)
        {
            HttpResponseMessage message;
            try
            {
                DepartmentDAL dal = new DepartmentDAL();
                var dynobj = new { result = dal.SaveDepartment(obj) };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }

        [HttpPost]
        public HttpResponseMessage ModifyDepartment(ModifyDepartmentDTO obj)
        {
            HttpResponseMessage message;
            try
            {
                DepartmentDAL dal = new DepartmentDAL();
                var dynobj = new { result = dal.ModifyDepartment(obj) };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
        [HttpPost]
        public HttpResponseMessage RemoveDepartment(RemoveDepartmentDTO obj)
        {
            HttpResponseMessage message;
            try
            {
                DepartmentDAL dal = new DepartmentDAL();
                var dynobj = new { result = dal.RemoveDepartment(obj) };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
        [HttpPost]
        public HttpResponseMessage SelectDepartment()
        {
            HttpResponseMessage message;
            try
            {
                DepartmentDAL dal = new DepartmentDAL();
                var dynobj = new { result = dal.SelectDepartment() };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
        [HttpPost]
        public HttpResponseMessage SelectCollegeName()
        {
            HttpResponseMessage message;
            try
            {
                DepartmentDAL dal = new DepartmentDAL();
                var dynobj = new { result = dal.SelectCollegeName() };
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
