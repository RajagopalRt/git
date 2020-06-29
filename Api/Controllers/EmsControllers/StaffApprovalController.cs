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
    public class StaffApprovalController : ApiController
    {
        [HttpPost]
        public HttpResponseMessage SaveStaffApproval(SaveStaffApprovalDTO obj)
        {
            HttpResponseMessage message;
            try
            {
                StaffApprovalDAL dal = new StaffApprovalDAL();
                var dynobj = new { result = dal.SaveStaffApproval(obj) };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
        [HttpPost]
        public HttpResponseMessage RemoveStaffApproval(RemoveStaffApprovalDTO obj)
        {
            HttpResponseMessage message;
            try
            {
                StaffApprovalDAL dal = new StaffApprovalDAL();
                var dynobj = new { result = dal.RemoveStaffApproval(obj) };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }

        [HttpPost]
        public HttpResponseMessage SelectStaffApproval(SelectStaffApprovalProcDTO obj)
        {
            HttpResponseMessage message;
            try
            {
                StaffApprovalDAL dal = new StaffApprovalDAL();
                var dynobj = new { result = dal.SelectStaffApproval(obj) };
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
