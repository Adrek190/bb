# اختبار النظام الجديد للفواتير

## اختبار دالة إرسال طلب دفع

```sql
-- اختبار إرسال طلب دفع لفاتورة موجودة
SELECT submit_bill_payment_request(
    'a6b965b8-38bb-4782-b32a-fad2134a9c3c'::UUID, -- معرف الفاتورة
    '550e8400-e29b-41d4-a716-446655440000'::UUID, -- معرف الوالد
    (SELECT bank_id FROM banks LIMIT 1), -- معرف البنك الأول
    'TR123456789', -- رقم الحوالة
    '/images/receipt123.jpg', -- مسار صورة الإيصال
    400.00 -- المبلغ
);
```

## اختبار عرض الفواتير تحت المراجعة

```sql
-- عرض الفواتير تحت المراجعة للوالد
SELECT * FROM get_bills_under_review('550e8400-e29b-41d4-a716-446655440000'::UUID);
```

## اختبار تأكيد الدفع

```sql
-- تأكيد طلب الدفع (للإدارة)
SELECT approve_payment_request(
    (SELECT request_id FROM bill_payment_requests LIMIT 1),
    '00000000-0000-0000-0000-000000000001'::UUID, -- معرف المدير
    'تم التحقق من الحوالة البنكية وتأكيد الدفع'
);
```

## اختبار عرض الفواتير المدفوعة

```sql
-- عرض الفواتير المدفوعة للوالد
SELECT * FROM get_paid_bills('550e8400-e29b-41d4-a716-446655440000'::UUID);
```

## فحص حالة الجداول

```sql
-- فحص الجداول الجديدة
SELECT 
    'bill_payment_requests' as table_name,
    COUNT(*) as count
FROM bill_payment_requests
UNION ALL
SELECT 
    'paid_bills' as table_name,
    COUNT(*) as count
FROM paid_bills;
```

## فحص الفواتير الحالية

```sql
-- فحص الفواتير غير المدفوعة
SELECT 
    bill_id,
    bill_number,
    status,
    amount
FROM bills 
WHERE parent_id = '550e8400-e29b-41d4-a716-446655440000'::UUID
AND is_active = true
ORDER BY created_at DESC;
```
