# NWLayoutInflator

A project that lets you create UIView subclasses with XML. If you have a file named testLayout.xml:

```xml
<NWLayoutView>
  <UILabel text="Hello World!" id="label" x="20" y="50" sizeToFit="1" backgroundColor="#FFE0A0" />
  <UIButton id="clickme" onclick="moveFrame" text="Click Me" textColor="white" cornerRadius="5" below="label" alignLeft="label" sizeToFit="1" backgroundColor="#40FF0000" marginTop="5" borderColor="black" borderWidth="1" />
  <UILabel id="ontheright" text="on the right" sizeToFit="1" textColor="#D030A0" toRightOf="clickme" alignTop="clickme" marginLeft="10" />
  <UIImageView id="image" below="ontheright" alignLeft="ontheright" width="50" height="50" imageNamed="camera_button_blue" />
</NWLayoutView>
```

![Screen shot of example xml](https://github.com/nickwah/NWLayoutInflator/blob/master/testLayoutExample.png)

In your viewcontroller you can inflate this into a UIView hierarchy:

```objective-c
@implementation ViewController {
  NWLayoutView *_layoutView;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  _layoutView = [[NWLayoutView alloc] initWithLayout:@"testLayout" andFrame:self.view.bounds andDelegate:self];
  [self.view addSubview:_layoutView];
}

- (void)moveFrame {
  _layoutView.frame = CGRectMake(120, 20, 200, 200);
}
```

You can also grab a specific view from the hierarchy by the id: `(UIButton*)[_layoutView findViewById:@"clickme"]`

Note: if you're using AFNetworking, you can also load a `UIImageView` with an image URL:
```xml
  <UIImageView imageWithURL="http://my.example.com/image.png" />
```

You can nest UIViews:
```xml
<UIView id="container" width="150" height="100">
  <UILabel x="0" sizeToFit="1" text="Left side" />
  <UILabel right="0" sizeToFit="1" text="Right side" />
</UIView>
```

`sizeToFit="1"` will also work on containers, but beware that there is no padding, and margins are not taken into consideration for size purposes, only for positioning the subviews themselves. I currently use empty `UIView`s as spacers. I know, that's lame, so I'll probably fix the layout soonish.

New: You can now set any value to a variable using curly brackets: `text="{{ user_name }}"` and `[layoutView setDictValue:@"Nick" forKey:@"user_name"]`. If you change values, you may want to force layout to happen again, such as by setting the frame: `layoutView.frame = layoutView.frame;`

## CSS Styling

Create a file with the suffix `.css`. Normal comments are supported (both /* .. */ and // to end of line). Only two types of selectors are supported, classes and ids, and selectors must be simple. To be precise, only .class or #id can be before the `{`. Id-based selectors override classes, and inline styles override everything.

```css
// This is buttons.css
.button {
  backgroundColor: #FF0000;
  cornerRadius: 3
}
#red_button {
  textColor: #FF0000;
}
```

Specify the stylesheet by adding `stylesheet="buttons"` to the NWLayoutView xml statement.