<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PubnubTest.aspx.cs" Inherits="csharp_webApp.PubnubTest" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    <table width="50%">
    <tr >
    <td align="left">
        <asp:Label ID="Label1" runat="server" Text="Example to publish messages" 
            Font-Size="Medium"></asp:Label>
    </td></tr>
    <tr>
    <td height="10px"></td></tr>
    <tr>
    <td align="left">
        <asp:Button ID="btnPublish" runat="server" Text="Publish" 
            onclick="btnPublish_Click" />
    </td>
    </tr>
    <tr><td height="10"></td></tr>
    </table>
    <table width="50%">
    <tr >
    <td align="left">
    <asp:Label ID="Label2" runat="server" Text=" Example to receive published messages" 
     Font-Size="Medium"></asp:Label>
    </td></tr>
    <tr>
    <td height="10"></td></tr>
    <tr>
    <td align="left">
    <asp:Button ID="btnSubscribe" runat="server" Text="Subscribe" 
    onclick="btnSubscribe_Click" style="height: 26px" />
    </td>
    </tr>
    <tr><td height="10"></td></tr>
    </table>
    <table width="50%">
    <tr >
    <td align=left>
        <asp:Label ID="Label8" runat="server" Text=" Example to get history of publish messages" 
             Font-Size="Medium"></asp:Label>
    </td></tr>
    <tr>
    <td height="10px"></td></tr>
    <tr>
    <td align="left">
        <asp:Button ID="btnHistory" runat="server" Text="History" 
            onclick="btnHistory_Click" />
    </td>
    </tr>
    <tr><td height="10"></td></tr>
    </table>
    <table width="50%">
    <tr >
    <td align=left>
    <asp:Label ID="Label6" runat="server" Text=" Example to get server time " 
     Font-Size="Medium"></asp:Label>
    </td></tr>
    <tr>
    <td height="10px"></td></tr>
    <tr>
    <td align="left">
    <asp:Button ID="btnTime" runat="server" Text="Time" 
    onclick="btnTime_Click" />
    </td>
    </tr>
    <tr><td height="10"></td></tr>
    </table>
    <table width="50%">
    <tr >
    <td align=left>
        <asp:Label ID="Label4" runat="server" Text=" Example to get UUID " 
             Font-Size="Medium"></asp:Label>
    </td></tr>
    <tr>
    <td height="10px"></td></tr>
    <tr>
    <td align="left">
        <asp:Button ID="btnUUID" runat="server" Text="UUID" 
            onclick="btnUUID_Click" />
    </td>
    </tr>
    </table>
    </div>
    </form>
</body>
</html>
