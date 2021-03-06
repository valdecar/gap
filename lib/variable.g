#############################################################################
##
#W  variable.g                  GAP library                      Frank Celler
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the functions for the special handling of those global
##  variables in {\GAP} library files that are *not* functions;
##  they are declared with `DeclareGlobalVariable' and initialized with
##  `InstallValue' resp.~`InstallFlushableValue'.
##
##  For the global functions in the {\GAP} libraray, see `oper.g'.
##


#############################################################################
##

#C  IsToBeDefinedObj. . . . . . . .  represenation of "to be defined" objects
##
DeclareCategory( "IsToBeDefinedObj", IsObject );


#############################################################################
##
#V  ToBeDefinedObjFamily  . . . . . . . . . family of "to be defined" objects
##
BIND_GLOBAL( "ToBeDefinedObjFamily",
    NewFamily( "ToBeDefinedObjFamily", IsToBeDefinedObj ) );


#############################################################################
##
#V  ToBeDefinedObjType  . . . . . . . . . . . type of "to be defined" objects
##
BIND_GLOBAL( "ToBeDefinedObjType", NewType(
    ToBeDefinedObjFamily, IsPositionalObjectRep ) );


#############################################################################
##
#F  NewToBeDefinedObj() . . . . . . . . . create a new "to be defined" object
##
BIND_GLOBAL( "NewToBeDefinedObj",
    name -> Objectify( ToBeDefinedObjType, [ name ] ) );


#############################################################################
##
#M  PrintObj( <obj> ) . . . . . . . . . . . . .  print "to be defined" object
##
InstallMethod( PrintObj,
    "for 'to be defined' objects",
    [ IsToBeDefinedObj ],
function(obj)
    Print( "<< ",obj![1]," to be defined>>" );
end );


#############################################################################
##
#O  FlushCaches( ) . . . . . . . . . . . . . . . . . . . . . Clear all caches
##
##  <#GAPDoc Label="FlushCaches">
##  <ManSection>
##  <Oper Name="FlushCaches" Arg=""/>
##
##  <Description>
##  <Ref Func="FlushCaches"/> resets the value of each global variable that
##  has been declared with <Ref Func="DeclareGlobalVariable"/> and for which
##  the initial value has been set with <Ref Func="InstallFlushableValue"/>
##  or <Ref Func="InstallFlushableValueFromFunction"/>
##  to this initial value.
##  <P/>
##  <Ref Func="FlushCaches"/> should be used only for debugging purposes,
##  since the involved global variables include for example lists that store
##  finite fields and cyclotomic fields used in the current &GAP; session,
##  in order to avoid that these fields are constructed anew in each call
##  to <Ref Func="GF" Label="for field size"/> and
##  <Ref Func="CF" Label="for (subfield and) conductor"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "FlushCaches", [] );
# This method is just that one method is callable. It is installed first, so
# it will be last in line.
InstallMethod( FlushCaches, "return method", [], function() end );


#############################################################################
##
#F  DeclareGlobalVariable( <name>[, <description>] )
##
##  <#GAPDoc Label="DeclareGlobalVariable">
##  <ManSection>
##  <Func Name="DeclareGlobalVariable" Arg="name[, description]"/>
##
##  <Description>
##  For global variables that are <E>not</E> functions,
##  instead of using <Ref Func="BindGlobal"/> one can also declare the
##  variable with <Ref Func="DeclareGlobalVariable"/>
##  which creates a new global variable named by the string <A>name</A>.
##  If the second argument <A>description</A> is entered then this must be
##  a string that describes the meaning of the global variable.
##  <Ref Func="DeclareGlobalVariable"/> shall be used in the declaration part
##  of the respective package
##  (see&nbsp;<Ref Sect="Declaration and Implementation Part"/>),
##  values can then be assigned to the new variable with
##  <Ref Func="InstallValue"/>, <Ref Func="InstallFlushableValue"/> or
##  <Ref Func="InstallFlushableValueFromFunction"/>,
##  in the implementation part
##  (again, see&nbsp;<Ref Sect="Declaration and Implementation Part"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "DeclareGlobalVariable", function( arg )
    BIND_GLOBAL( arg[1], NewToBeDefinedObj(arg[1]) );
end );


#############################################################################
##
#F  InstallValue( <gvar>, <value> )
#F  InstallFlushableValue( <gvar>, <value> )
#F  InstallFlushableValueFromFunction( <gvar>, <func> )
##
##  <#GAPDoc Label="InstallValue">
##  <ManSection>
##  <Func Name="InstallValue" Arg="gvar, value"/>
##  <Func Name="InstallFlushableValue" Arg="gvar, value"/>
##  <Func Name="InstallFlushableValueFromFunction" Arg="gvar, func"/>
##
##  <Description>
##  <Ref Func="InstallValue"/> assigns the value <A>value</A> to the global
##  variable <A>gvar</A>.
##  <Ref Func="InstallFlushableValue"/> does the same but additionally
##  provides that each call of <Ref Func="FlushCaches"/>
##  will assign a structural copy of <A>value</A> to <A>gvar</A>.
##  <Ref Func="InstallFlushableValueFromFunction"/> instead assigns
##  the result of <A>func</A> to <A>gvar</A> (<A>func</A> is re-evaluated
##  for each invocation of <Ref Func="FlushCaches"/>
##  <P/>
##  <Ref Func="InstallValue"/> does <E>not</E> work if <A>value</A> is an
##  <Q>immediate object</Q>, i.e., an internally represented small integer or
##  finite field element. It also fails for booleans.
##  Furthermore, <Ref Func="InstallFlushableValue"/> works only if
##  <A>value</A> is a list or a record.
##  (Note that <Ref Func="InstallFlushableValue"/> makes sense only for
##  <E>mutable</E> global variables.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  Using `DeclareGlobalVariable' and `InstallFlushableValue' has several
##  advantages, compared to simple assignments.
##  1. The initial value must be written down only once in the file;
##     this is an argument in particular for the variable `Primes2'.
##  2. The implementation of `FlushCaches' is not prescribed,
##     at least it is hidden in the function `InstallFlushableValue'.
##  3. It is possible to access the `#V' global variables from within GAP,
##     perhaps separately for each package.
##     Note that the assignments of other global variables via
##     `DeclareOperation', `DeclareProperty' etc. would admit this already.
##

BIND_GLOBAL("UNCLONEABLE_TNUMS",MakeImmutable([0,5,8]));

BIND_GLOBAL( "InstallValue", function ( gvar, value )
    if (not IsBound(REREADING) or REREADING = false) and not
       IsToBeDefinedObj( gvar ) then
        Error("InstallValue: a value has been installed already");
    fi;
    if IsFamily( value ) then
      INFO_DEBUG( 1,
          "please use `BindGlobal' for the family object ",
          value!.NAME, ", not `InstallValue'" );
    fi;
    if TNUM_OBJ_INT(value) in UNCLONEABLE_TNUMS then
       Error("InstallValue: <value> cannot be immediate, boolean or character");
    fi;
    CLONE_OBJ (gvar, value);
end);

BIND_GLOBAL( "InstallFlushableValueFromFunction", function( gvar, func )
    local initval, flushfunc, ret;

    # Initialize the variable.
    ret := func();
    InstallValue(gvar, ret);

    # Install the method to flush the cache.
    InstallMethod( FlushCaches,
      [],
      function()
         local ret;
         ret := func();
         CLONE_OBJ(gvar, ret);
         gvar := ret;
        TryNextMethod();
      end );
end );


BIND_GLOBAL( "InstallFlushableValue", function( gvar, value )
    local initval;

    if not ( IS_LIST( value ) or IS_REC( value ) ) then
      Error( "InstallFlushableValue: <value> must be a list or a record" );
    fi;

    # Make a structural copy of the initial value.
    initval:= DEEP_COPY_OBJ( value );

    # Initialize the variable.
    InstallValue( gvar, value );

    # Install the method to flush the cache.
    InstallMethod( FlushCaches,
      [],
      function()
          CLONE_OBJ( gvar, DEEP_COPY_OBJ( initval ) );
          TryNextMethod();
      end );
end );

##  Bind some keywords as global variables such that <Tab> completion works
##  for them. These variables are not accessible.
BIND_GLOBAL( "Unbind", 0 );
BIND_GLOBAL( "true", 0 );
BIND_GLOBAL( "false", 0 );
BIND_GLOBAL( "while", 0 );
BIND_GLOBAL( "repeat", 0 );
BIND_GLOBAL( "until", 0 );
#BIND_GLOBAL( "SaveWorkspace", 0 );
BIND_GLOBAL( "else", 0 );
BIND_GLOBAL( "elif", 0 );
BIND_GLOBAL( "function", 0 );
BIND_GLOBAL( "local", 0 );
BIND_GLOBAL( "return", 0 );
BIND_GLOBAL( "then", 0 );
BIND_GLOBAL( "quit", 0 );
BIND_GLOBAL( "break", 0 );
BIND_GLOBAL( "continue", 0 );
BIND_GLOBAL( "IsBound", 0 );
BIND_GLOBAL( "TryNextMethod", 0 );
BIND_GLOBAL( "Info", 0 );
BIND_GLOBAL( "Assert", 0 );

#
# Type for lvars bags
#

DeclareCategory("IsLVarsBag", IsObject);
BIND_GLOBAL( "LVARS_FAMILY", NewFamily(IsLVarsBag, IsLVarsBag));
BIND_GLOBAL( "TYPE_LVARS", NewType(LVARS_FAMILY, IsLVarsBag));

#############################################################################
#
# Namespaces:
#
BIND_GLOBAL( "NAMESPACES_STACK", [] );

BIND_GLOBAL( "ENTER_NAMESPACE",
  function( namesp )
    if not(IS_STRING_REP(namesp)) then
        Error( "<namesp> must be a string" );
        return;
    fi;
    NAMESPACES_STACK[LEN_LIST(NAMESPACES_STACK)+1] := namesp;
    SET_NAMESPACE(namesp);
  end );

BIND_GLOBAL( "LEAVE_NAMESPACE",
  function( )
    if LEN_LIST(NAMESPACES_STACK) = 0 then
        SET_NAMESPACE("");
        Error( "was not in any namespace" );
    else
        UNB_LIST(NAMESPACES_STACK,LEN_LIST(NAMESPACES_STACK));
        if LEN_LIST(NAMESPACES_STACK) = 0 then
            SET_NAMESPACE("");
        else
            SET_NAMESPACE(NAMESPACES_STACK[LEN_LIST(NAMESPACES_STACK)]);
        fi;
    fi;
  end );

BIND_GLOBAL( "LEAVE_ALL_NAMESPACES",
  function( )
    local i;
    SET_NAMESPACE("");
    for i in [1..LEN_LIST(NAMESPACES_STACK)] do
         UNB_LIST(NAMESPACES_STACK,i);
    od;
  end );
    
BIND_GLOBAL( "CURRENT_NAMESPACE",
  function()
    if LEN_LIST(NAMESPACES_STACK) > 0 then
        return NAMESPACES_STACK[LEN_LIST(NAMESPACES_STACK)];
    else
        return "";
    fi;
  end );

#############################################################################
##

#E
