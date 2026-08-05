/**
 * Created by artsiomartsiomenka on 27/03/2024.
 */
global class ClickUpAPIServiceMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        String endpoint = req.getEndpoint();
        String method = req.getMethod();

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');

        if (endpoint.contains('/time/')) {
            res.setBody('{ "data": [ { "user": { "id": "cid123", "username": "Artsiom", "email": "test@pp.test", ' +
                    '"color": "#8077f1", "initials": "AA", "profilePicture": null }, "time": 3600000, ' +
                    '"intervals": [{ "id": "ttid123", "start": "1709401920000", "end": "1709405520000", "time": "3600000", ' +
                    '"source": "clickup", "date_added": "1709664787199", "billable": false, "description": "Test time estimate", ' +
                    '"tags": null } ] } ] }');
        }
        if (endpoint.contains('task/') && !endpoint.contains('/time/')) {
            res.setBody('{ "id": "tid123", "custom_id": null, "custom_item_id": "0", "name": "ClickUp - SF", "text_content": "test", ' +
                    '"description": "test", "status": { "id": "p9017060", "status": "in progress", "color": "#1090e0", "orderindex": 1,' +
                    ' "type": "custom" }, "orderindex": "39", "date_created": "1705328414056", "date_updated": "1709667318911", ' +
                    '"date_closed": null, "date_done": null, "archived": false, "creator": { "id": "123", "username": "Vlad", ' +
                    '"color": "#8ac34a", "email": "testV@pp.test", "profilePicture": null }, "assignees": [ { "id": "123", ' +
                    '"username": "Artsiom", "color": "#8077f1", "initials": "AA", "email": "test@pp.test", "profilePicture": null } ],' +
                    ' "watchers": [ { "id": "123", "username": "Artsiom", "color": "#8077f1", "initials": "AA", "email": "test@pp.test", ' +
                    '"profilePicture": null } ], "checklists": [], "tags": [ { "name": "test exp", "tag_fg": "#8077F1",' +
                    ' "tag_bg": "#8077F1", "creator": "123" } ], "parent": null, "priority": { "color": "#f50000", "id": "1", ' +
                    '"orderindex": "1", "priority": "urgent" }, "due_date": "1712282400000", "start_date": null, "points": null, ' +
                    '"time_estimate": null, "time_spent": 3600000, "custom_fields": [ ' +
                    '{ "id": "3dd354", "name": "Priority", "type": "drop_down", "type_config": { "options": [ { "id": "cc2bdb16", "name": "High", "color": "#ff7800",' +
                    ' "orderindex": 0 }, { "id": "cb1fa2", "name": "Medium", "color": "#f9d900", "orderindex": 1 }, ' +
                    '{ "id": "3117f", "name": "Low", "color": "#2ecd6f", "orderindex": 2 }, {\n' +
                    '            "id": "67",\n' +
                    '            "name": "External ID",\n' +
                    '            "type": "short_text",\n' +
                    '            "type_config": {},\n' +
                    '            "date_created": "1707379936497",\n' +
                    '            "hide_from_guests": false,\n' +
                    '            "value": "T-1",\n' +
                    '            "required": false\n' +
                    '        },\n' +
                    '        {\n' +
                    '            "id": "bf579e",\n' +
                    '            "name": "External URL",\n' +
                    '            "type": "url",\n' +
                    '            "type_config": {},\n' +
                    '            "date_created": "1707380122826",\n' +
                    '            "hide_from_guests": false,\n' +
                    '            "value": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",\n' +
                    '            "required": false\n' +
                    '        },\n' +
                    '        {\n' +
                    '            "id": "cbe9",\n' +
                    '            "name": "Salesforce ID",\n' +
                    '            "type": "short_text",\n' +
                    '            "type_config": {},\n' +
                    '            "date_created": "1707379904544",\n' +
                    '            "hide_from_guests": true,\n' +
                    '            "value": "SF-1",\n' +
                    '            "required": false\n' +
                    '        } ] }, "date_created": "1705925780738", ' +
                    '"hide_from_guests": false, "value": 0, "required": false } ], "dependencies": [ { "task_id": "tid1234",' +
                    ' "depends_on": "86dr6qz2v", "type": 1, "date_created": "1705328654779", "userid": "123", "workspace_id": ' +
                    '"wid123" } ], "linked_tasks": [], "locations": [], "team_id": "tmid123", "url": null, "sharing": ' +
                    '{ "public": false, "public_share_expires_on": null, "public_fields": [ "assignees", "priority", "due_date", ' +
                    '"content", "comments", "attachments", "customFields", "subtasks", "tags", "checklists", "coverimage" ], ' +
                    '"token": null, "seo_optimized": false }, "permission_level": "create", "list": { "id": "lid123",' +
                    ' "name": "Q1-24", "access": true }, "project": { "id": "pid123", "name": "hidden", "hidden": true, ' +
                    '"access": true }, "folder": { "id": "fid123", "name": "hidden", "hidden": true, "access": true }, ' +
                    '"space": { "id": "sid123" }, "attachments": [] }');
        }

        res.setStatusCode(200);
        return res;
    }
}