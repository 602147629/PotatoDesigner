package potato.designer.plugin.uidesigner.construct
{
	import core.display.DisplayObject;
	import core.display.DisplayObjectContainer;
	
	import flash.utils.getDefinitionByName;
	
	import potato.designer.plugin.uidesigner.Const;
	
	
	
	/**
	 *基础构建器
	 * <br>此构建器可以为变量和可写的存取器赋值，以及对象的调用成员方法。 
	 * @author Just4test
	 * 
	 */
	public class BasicConstructor implements IConstructor
	{
		protected static var classTable:Object = {};
		protected static var classMemberTable:Object = {};
		/**
		 *设置类描述文件
		 * <br>使用类描述文件来让构建器确定如何配合组件描述文件来构建组件。
		 * <br>部分构建器可能不需要类描述文件。
		 */
		public static function setClassTypeProfile(profile:BasicClassTypeProfile):void
		{
			classTable[profile.className] = profile;
			classMemberTable[profile.className] = {};
			
			for each (var i:int in profile.memberTypeTable) 
			{
				//TODO
			}
		}
		
		/**
		 *获取类描述文件
		 * <br>使用类描述文件来让构建器确定如何配合组件描述文件来构建组件。
		 * <br>部分构建器可能不需要类描述文件。
		 */
		public static function getClassTypeProfile(className:String):BasicClassTypeProfile
		{
			return classTable[className];
		}
		
		public static const instance:BasicConstructor = new BasicConstructor;
		
		public function construct(profile:IComponentProfile, tree:ComponentTree):Boolean
		{
			//如果配置文件不是所需要的格式则跳过本构建器
			var basicProfile:BasicComponentProfile = profile as BasicComponentProfile;
			if(!basicProfile)
			{
				return false;
			}
			var classProfile:BasicClassTypeProfile = getClassTypeProfile(basicProfile.className);
			if(!classProfile)
			{
				throw new Error("组件配置文件中使用的类[" + basicProfile.className + "]找不到对应的类配置文件");
			}
			
			//如果没有传入组件，则创建组件
			var component:* = tree.component;
			if(!component)
			{
				var array:Array = classMemberTable[basicProfile.className][basicProfile.className](basicProfile.getConstructor());
				var C:Class = getDefinitionByName(basicProfile.className) as Class;
				switch(array.length)
				{
					case 0:
						component = new C();
						break;
					case 1:
						component = new C(array[0]);
						break;
					case 2:
						component = new C(array[0], array[1]);
						break;
					case 3:
						component = new C(array[0], array[1], array[2]);
						break;
					case 4:
						component = new C(array[0], array[1], array[2], array[3]);
						break;
					case 5:
						component = new C(array[0], array[1], array[2], array[3], array[4]);
						break;
					case 6:
						component = new C(array[0], array[1], array[2], array[3], array[4], array[5]);
						break;
					case 7:
						component = new C(array[0], array[1], array[2], array[3], array[4], array[5], array[6]);
						break;
					case 8:
						component = new C(array[0], array[1], array[2], array[3], array[4], array[5], array[6], array[7]);
						break;
					case 9:
						component = new C(array[0], array[1], array[2], array[3], array[4], array[5], array[6], array[7], array[8]);
						break;
					case 10:
						component = new C(array[0], array[1], array[2], array[3], array[4], array[5], array[6], array[7], array[8], array[9]);
						break;
					default:
						throw new Error("类的参数个数过多");
				}
				tree.component = component;
			}
			
			//遍历
			var memberTable:Object = classMemberTable[basicProfile.className];
			for each (var member:BasicComponentMemberProfile in basicProfile.member) 
			{
				var f:Function;
				switch(classProfile.getMemberType(member.name))
				{
					case 0:
						throw new Error();
						break;
					case BasicClassTypeProfile.TYPE_ACCESSOR:
						component[member.name] = memberTable[member.name](member.values[0]);
						break;
					case BasicClassTypeProfile.TYPE_METHOD:
						
						Function(component[member.name]).apply(null, memberTable[member.name](member.values));
						break;
					
					default:
						throw new Error("类配置文件指定的成员类型[" + classProfile.getMemberType(member.name) + "]无法理解");
				}
			}

			return false;
		}
		
		public function addChildren(profile:IComponentProfile, tree:ComponentTree):Boolean
		{
			var container:DisplayObjectContainer = tree.component as DisplayObjectContainer;
			for (var i:int = 0; i < tree.children.length; i++) 
			{
				var disObj:DisplayObject = tree.children[i] as DisplayObject;
				if(disObj)
				{
					container.addChild(disObj);
				}
			}
			
			return false;
		}
		
		protected static function makeMemberFunction(className:String, memberName:String):Function
		{
			var classProfile:BasicClassTypeProfile = getClassTypeProfile(className);
			var memberTable:Object = classMemberTable[className];
			
			var f:Function;
			
			switch(classProfile.getMemberType(memberName))
			{
				case 0:
					throw new Error();
					break;
				case BasicClassTypeProfile.TYPE_ACCESSOR:
//					var getter:Function =  TODO
					break;
				case BasicClassTypeProfile.TYPE_METHOD:
					break;
				
				default:
					throw new Error("类配置文件指定的成员类型[" + classProfile.getMemberType(memberName) + "]无法理解");
			}
			
			return null;
		}
		
		public function setData(data:*):Boolean
		{
			if(null == data)
			{
				classTable = {};
				classMemberTable = {};
				Factory.clearComponentProfile();
				return false;
			}
			try
			{
				//读取类描述文件
				if(data.hasOwnProperty(Const.CONSTRUCTOR_CLASS_TYPE_PROFILE))
				{
					var types:Vector.<BasicClassTypeProfile> = Vector.<BasicClassTypeProfile>(data[Const.CONSTRUCTOR_CLASS_TYPE_PROFILE]);
					for each(var typeProfile:BasicClassTypeProfile in types)
					{
						setClassTypeProfile(typeProfile);
					}
				}
				
				//读取并设置组件描述文件
				if(data.hasOwnProperty(Const.CONSTRUCTOR_COMPONENT_PROFILE))
				{
					var componentTable:Object = data[Const.CONSTRUCTOR_COMPONENT_PROFILE]
					for each(var name:String in componentTable)
					{
						Factory.setComponentProfile(componentTable[name], name);
					}
				}
			} 
			catch(error:Error) 
			{
				
			}
			return false;
		}
	}
}