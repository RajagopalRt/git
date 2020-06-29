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
    public class StaffAllocationController : ApiController
    {
        [HttpPost]
        public HttpResponseMessage SaveStaffAllocation(saveStaffAllocationDTO obj)
        {
            HttpResponseMessage message;
            try
            {
                StaffAllocationDAL dal = new StaffAllocationDAL();
                var dynobj = new { result = dal.SaveStaffAllocation(obj) };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }

        [HttpPost]
        public HttpResponseMessage ModifyStaffAllocation(ModifyStaffAllocationDTO obj)
        {
            HttpResponseMessage message;
            try
            {
                StaffAllocationDAL dal = new StaffAllocationDAL();
                var dynobj = new { result = dal.ModifyStaffAllocation(obj) };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
        [HttpPost]
        public HttpResponseMessage RemoveStaffAllocation(RemoveStaffAllocationDTO obj)
        {
            HttpResponseMessage message;
            try
            {
                StaffAllocationDAL dal = new StaffAllocationDAL();
                var dynobj = new { result = dal.RemoveStaffAllocation(obj) };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
        [HttpPost]
        public HttpResponseMessage SelectStaffAllocation()
        {
            HttpResponseMessage message;
            try
            {
                StaffAllocationDAL dal = new StaffAllocationDAL();
                var dynobj = new { result = dal.SelectStaffAllocationt() };
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
