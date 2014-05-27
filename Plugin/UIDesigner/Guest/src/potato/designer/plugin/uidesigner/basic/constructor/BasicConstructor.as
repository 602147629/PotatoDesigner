package potato.designer.plugin.uidesigner.basic.constructor
{
	import flash.net.registerClassAlias;
	import flash.utils.getDefinitionByName;
	
	import core.display.DisplayObject;
	import core.display.DisplayObjectContainer;
	import core.display.Texture;
	import core.display.TextureData;
	
	import potato.designer.plugin.uidesigner.basic.BasicConst;
	import potato.designer.plugin.uidesigner.construct.ComponentTree;
	import potato.designer.plugin.uidesigner.construct.Factory;
	import potato.designer.plugin.uidesigner.construct.IComponentProfile;
	import potato.designer.plugin.uidesigner.construct.IConstructor;
	
	
	
	/**
	 *基础构建器
	 * <br>此构建器可以为变量和可写的存取器赋值，以及对象的调用成员方法。只要这些变量/存取器的值，或者成员方法的参数可以由字符串转换得到。
	 * @author Just4test
	 * 
	 */
	public class BasicConstructor implements IConstructor
	{
		
		public static function init():void
		{
			
			Factory.constructorList.push(instance);
			
			registerClassAlias("BasicClassProfile", BasicClassProfile);
			
			regType("int", getInt, true, "int");
			regType("Number", getNumber, true, "Number");
			regType("String", getString, true, "String");
			regType("Texture", getTexture, false, "core.display::Texture");
			regType("TextureData", getTextureData, false, "core.display::TextureData");
		}
		
		
		protected static var _typeTable:Object = {};
		protected static var _classTable:Object = {};
		protected static var _classMemberTable:Object = {};
		
		
		
		/**
		 * 注册类型
		 * <br>类型是一种翻译机制：它将字符串翻译为目标值。
		 * <br>可以为类型指定一个目标类，这意味着声明了翻译结果是该目标类的实例。构建器并不检查翻译结果是否真的是目标类。
		 * <br>一个目标类可以对应多个类型。在Host端指定属性/参数类型时，设计器将提示用户与需要的类对应的所有类型。
		 * 然而，允许指定与目标类不匹配的类型。比如，需要Number类时，可以手动输入int类型。设计器不会检查类型是否匹配。
		 * @param typeName 类型名
		 * @param translater 翻译器。这是一个方法，它接受一个String作为参数，并返回目标类型
		 * @param isSerializable 指示翻译器的返回是否可以序列化。如果该参数为true，则发布版中将仅包含翻译过的结果，而不是初始的String。这样做可以加速发行版本的构建速度。
		 * @param className 指示该类型所对应的目标类。
		 * 
		 */
		public static function regType(typeName:String, translater:Function, isSerializable:Boolean = false, className:String = null):void
		{
			_typeTable[typeName] = new BasicTypeProfile(typeName, translater, isSerializable, className);
		}
		
		/**
		 *获取已经注册的类型配置文件。
		 */
		public static function getTypeProfile(typeName:String):BasicTypeProfile
		{
			return _typeTable[typeName];
		}
		
		/**
		 *获取类型与className对应表。Host端使用该对应表提示与需要的类所对应的类型。
		 * @return 一个Object。以类型作为key，目标类名作为value。
		 * 
		 */
		public static function get type2ClassNameTable():Object
		{
			var ret:Object = {};
			for(var i:String in _typeTable)
			{
				ret[i] = BasicTypeProfile(_typeTable[i]).typeName;
			}
			return ret;
		}
		
		
		/**
		 *设置类描述文件
		 * <br>使用类描述文件来让构建器确定如何配合组件描述文件来构建组件。
		 * <br>部分构建器可能不需要类描述文件。
		 */
		public static function setClassProfile(profile:BasicClassProfile):void
		{
			_classTable[profile.className] = profile;
			var memberTable:Object = {};
			_classMemberTable[profile.className] = memberTable;
			
			for each(var i:String in profile.memberTypeTable) 
			{
				var types:Vector.<String> = profile.getMethodParameters(i);
				var translaters:Vector.<Function> = new Vector.<Function>;
				
				for each(var j:String in types)
				{
					var typeProfile:BasicTypeProfile = getTypeProfile(j);
					if(!typeProfile)
						throw new Error("[基础构建器] 指定的type未注册：" + j);
				}
				
				
				memberTable[i] = function(paras:Array):Array
				{
					CONFIG::DEBUG
					{
						if(paras.length > translaters.length)
						{
							throw new Error("[基础构建器] 给予的参数比需要的参数多：" + profile.className + "::" + i);
						}
					}
					
					var ret:Array = [];
					for(var j:int = 0; j < paras.length; j++)
					{
						var translater:Function = translaters[i];
						
						if(CONFIG::DEBUG)
						{
							var value:*;
							try
							{
								value = translater ? translater(paras[i]): paras[i];
								ret.push(value);
							} 
							catch(error:Error) 
							{
								throw new Error("[基础构建器] 将\"" + paras[i] + "\"转换为[" + i + "]类型时发生错误" + error);
							}
						}
						else
						{
							ret.push(translater ? translater(paras[i]): paras[i]);
						}
						
						
					}
					return ret;
					
				}
			}
		}
		
		/**
		 *获取类描述文件
		 * <br>使用类描述文件来让构建器确定如何配合组件描述文件来构建组件。
		 * <br>部分构建器可能不需要类描述文件。
		 */
		public static function getClassProfile(className:String):BasicClassProfile
		{
			return _classTable[className];
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
			var classProfile:BasicClassProfile = getClassProfile(basicProfile.className);
			if(!classProfile)
			{
				throw new Error("组件配置文件中使用的类[" + basicProfile.className + "]找不到对应的类配置文件");
			}
			
			//如果没有传入组件，则创建组件
			var component:* = tree.component;
			if(!component)
			{
				var array:Array = _classMemberTable[basicProfile.className][basicProfile.className](basicProfile.getConstructor());
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
			var memberTable:Object = _classMemberTable[basicProfile.className];
			for each (var member:BasicComponentMemberProfile in basicProfile.member) 
			{
				var name:String = member.name;
				var F:Function = memberTable[name];
				CONFIG::DEBUG
				{
					if(!F)
					{
						throw new Error("组件描述文件指定的成员[" + name + "]在类描述文件中不存在");
					}
				}
				var values:Array;
				switch(classProfile.getMemberType(name))
				{
					case BasicClassProfile.TYPE_ACCESSOR:
						component[name] = F(member.values)[0];
						break;
					case BasicClassProfile.TYPE_METHOD:
						Function(component[name]).apply(null, F(member.values));
						break;
					
					default:
						throw new Error("类配置文件指定的成员类型[" + classProfile.getMemberType(name) + "]无法理解");
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
		
		public function setData(data:Object):Boolean
		{
			if(null == data)
			{
				_classTable = {};
				_classMemberTable = {};
				Factory.clearComponentProfile();
				return false;
			}
			try
			{
				//读取类描述文件
				if(data.hasOwnProperty(BasicConst.CONSTRUCTOR_CLASS_TYPE_PROFILE))
				{
					var types:Vector.<BasicClassProfile> = Vector.<BasicClassProfile>(data[BasicConst.CONSTRUCTOR_CLASS_TYPE_PROFILE]);
					for each(var typeProfile:BasicClassProfile in types)
					{
						setClassProfile(typeProfile);
					}
				}
				
				//读取并设置组件描述文件
				if(data.hasOwnProperty(BasicConst.CONSTRUCTOR_COMPONENT_PROFILE))
				{
					var componentTable:Object = data[BasicConst.CONSTRUCTOR_COMPONENT_PROFILE]
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
		
		//////////////////////基本的翻译器3+6-
		////////////////////////////////////////
		
		protected static function getInt(value:String):int
		{
			return int(value);
		}
		
		protected static function getNumber(value:String):Number
		{
			return Number(value);
		}
		
		protected static function getString(value:String):String
		{
			return value;
		}
		
		protected static function getTextureData(value:String):TextureData
		{
			try
			{
				return TextureData.createWithFile(value);
			}
			catch(e:Error)
			{
			}
			return null;
		}
		
		protected static function getTexture(value:String):Texture
		{
			try
			{
				return new Texture(TextureData.createWithFile(value));
			}
			catch(e:Error)
			{
			}
			return null;
		}
	}
}