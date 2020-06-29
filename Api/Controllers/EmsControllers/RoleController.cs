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
    public class RoleController : ApiController
    {
        [HttpPost]
        public HttpResponseMessage SaveRole(SaveRoleDTO obj)
        {
            HttpResponseMessage message;
            try
            {
                RoleDAL dal = new RoleDAL();
                var dynobj = new { result = dal.SaveRole(obj) };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }

        [HttpPost]
        public HttpResponseMessage ModifyRole(ModifyRoleDTO obj)
        {
            HttpResponseMessage message;
            try
            {
                RoleDAL dal = new RoleDAL();
                var dynobj = new { result = dal.ModifyRole(obj) };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
        [HttpPost]
        public HttpResponseMessage RemoveRole(RemoveRoleDTO obj)
        {
            HttpResponseMessage message;
            try
            {
                RoleDAL dal = new RoleDAL();
                var dynobj = new { result = dal.RemoveRole(obj) };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
        [HttpPost]
        public HttpResponseMessage SelectRole()
        {
            HttpResponseMessage message;
            try
            {
                RoleDAL dal = new RoleDAL();
                var dynobj = new { result = dal.SelectRole() };
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
