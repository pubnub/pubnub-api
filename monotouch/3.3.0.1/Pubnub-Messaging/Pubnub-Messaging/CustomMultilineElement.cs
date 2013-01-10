using System;
using MonoTouch.Dialog;
using MonoTouch.UIKit;
using MonoTouch.Foundation;

namespace PubnubMessaging
{
	public class CustomMultilineElement: StyledMultilineElement 
	{
		static NSString key = new NSString ("myDataElement");
		int iRows = 1;
		public CustomMultilineElement (string caption): base(caption)
		{
		}
		public void AppendValueAndUpdate (string value)
		{
			Value += Environment.NewLine + value;
			iRows++;
			if (GetContainerTableView () != null) {
				var root = GetImmediateRootElement ();

				MonoTouch.UIKit.UIApplication.SharedApplication.InvokeOnMainThread(delegate{root.Reload (this, UITableViewRowAnimation.Fade);});
			}
		}
		public override UITableViewCell GetCell (UITableView tv)
		{
			UITableViewCell cell = tv.DequeueReusableCell("myDataElement");
			if (cell == null)
			{
				cell = new UITableViewCell(UITableViewCellStyle.Default, "myDataElement");
			}
			cell.TextLabel.Text = Value;

			return cell;
		}
	}
	public class TableSource : UITableViewSource {
		string[] tableItems;
		string cellIdentifier = "TableCell";
		public TableSource (string[] items)
		{
			tableItems = items;
		}
		public override int RowsInSection (UITableView tableview, int section)
		{
			return tableItems.Length;
		}
		public override UITableViewCell GetCell (UITableView tableView, MonoTouch.Foundation.NSIndexPath indexPath)
		{
			UITableViewCell cell = tableView.DequeueReusableCell (cellIdentifier);
			// if there are no cells to reuse, create a new one
			if (cell == null)
				cell = new UITableViewCell (UITableViewCellStyle.Default, cellIdentifier);
			cell.TextLabel.Text = tableItems[indexPath.Row];
			return cell;
		}
	}
}

