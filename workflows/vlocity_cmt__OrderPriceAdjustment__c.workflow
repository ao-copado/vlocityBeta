<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>vlocity_cmt__ReferenceIdForOrderPriceAdjUpdate</fullName>
        <field>Name</field>
        <formula>Id</formula>
        <name>ReferenceIdForOrderPriceAdjUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>vlocity_cmt__ReferenceIdForOrderPriceAdjUpdate</fullName>
        <actions>
            <name>vlocity_cmt__ReferenceIdForOrderPriceAdjUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL(vlocity_cmt__Action__c, &apos;Add&apos;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
