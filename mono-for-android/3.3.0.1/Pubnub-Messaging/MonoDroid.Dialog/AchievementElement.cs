using System;
using Android.Content;
using Android.Graphics;
using Android.Views;
using Android.Widget;

namespace MonoDroid.Dialog
{
    public class AchievementElement : Element
    {
        
		public string Description
		{
			get;
			set;
		}
		
		public int PercentageComplete
		{
			get;
			set;
		}
		
		public Bitmap AchievementImage
		{
			get;
			set;
		}


        private ImageView _achivementImage;
        private TextView _caption;
        private TextView _description;
		private TextView _percentageComplete;

        public string Group;
		
		public AchievementElement(string caption, string description, int percentageComplete, Bitmap achievementImage)
            : base(caption, (int)DroidResources.ElementLayout.dialog_achievements)
        {
			Description = description;
			PercentageComplete = percentageComplete;
			AchievementImage = achievementImage;
        }
        
        public override View GetView(Context context, View convertView, ViewGroup parent)
        {
            View view = DroidResources.LoadAchievementsElementLayout(context, convertView, parent, LayoutId, out _caption, out _description, out _percentageComplete, out _achivementImage);
            if (view != null)
            {
                _caption.Text = Caption;                
				_description.Text = Description;
				_percentageComplete.Text = PercentageComplete.ToString();
				if ( AchievementImage != null )
				{
					_achivementImage.SetImageBitmap(AchievementImage);
				}
            }
			else
            {
                Android.Util.Log.Error("AchievementElement", "GetView failed to load template view");
            }
            return view;
        }
    }
}