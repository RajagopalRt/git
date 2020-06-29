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
    public class HODApprovalController : ApiController
    {
        [HttpPost]
        public HttpResponseMessage SaveHODApproval(SaveHODApprovalDTO obj)
        {
            HttpResponseMessage message;
            try
            {
                HODApprovalDAL dal = new HODApprovalDAL();
                var dynobj = new { result = dal.SaveHODApprovalDAL(obj) };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }

        [HttpPost]
        public HttpResponseMessage RemoveHODApproval(RemoveHODApprovalDTO obj)
        {
            HttpResponseMessage message;
            try
            {
                HODApprovalDAL dal = new HODApprovalDAL();
                var dynobj = new { result = dal.RemoveHODApproval(obj) };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
        [HttpPost]
        public HttpResponseMessage SelectHODApproval(SelectHODApprovalProcDTO obj)
        {
            HttpResponseMessage message;
            try
            {
                HODApprovalDAL dal = new HODApprovalDAL();
                var dynobj = new { result = dal.SelectHODApproval(obj) };
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
