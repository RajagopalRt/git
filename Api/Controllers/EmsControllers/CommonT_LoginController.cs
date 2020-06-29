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
    public class CommonT_LoginController : ApiController
    {
        [HttpPost]
        public HttpResponseMessage SaveCommonT_Login(SaveCommonT_LoginDTO obj)
        {
            HttpResponseMessage message;
            try
            {
                CommonT_LoginDAL dal = new CommonT_LoginDAL();
                var dynobj = new { result = dal.SaveCommonT_Login(obj) };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
        [HttpPost]
        public HttpResponseMessage ModifyCommonT_Login(ModifyCommonT_LoginDTO obj)
        {
            HttpResponseMessage message;
            try
            {
                CommonT_LoginDAL dal = new CommonT_LoginDAL();
                var dynobj = new { result = dal.ModifyCommonT_Login(obj) };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
        [HttpPost]
        public HttpResponseMessage SelectCommonT_Login(SelectCommonT_LoginProcDTO obj)
        {
            HttpResponseMessage message;
            try
            {
                CommonT_LoginDAL dal = new CommonT_LoginDAL();
                var dynobj = new { result = dal.SelectCommonT_Login(obj) };
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
