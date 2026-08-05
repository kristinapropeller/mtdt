/**
 * Created by artsiomartsiomenka on 03/04/2024.
 */

public without sharing class ClickUpWebhookRoute extends pp_RestRoute{
    protected override Boolean hasResource() {
        return false; //do parse the next url part as resourceId
    }

    protected override Map<String, pp_RestRoute> getNextRouteMap() {
        return new Map<String, pp_RestRoute>{ 'task' => new ClickUpTaskRoute() };
//        return new Map<String, pp_RestRoute>{ 'folder' => new ClickUpFolderRoute() };
    }
}